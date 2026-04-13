import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';
import '../core/constants.dart';
import 'package:flutter/material.dart';

class CommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Lấy danh sách bình luận và phân cấp (kèm reaction)
  Future<List<CommentModel>> getComments(String articleUrl) async {
    final currentUser = _supabase.auth.currentUser;

    // Lấy toàn bộ bình luận của bài báo đó
    final data = await _supabase
        .from('comments')
        .select('*')
        .eq('article_url', articleUrl)
        .order('created_at', ascending: true);

    final List<dynamic> list = data;

    // Chuyển dữ liệu thô thành Model phẳng
    List<CommentModel> allComments = list
        .map((json) => CommentModel.fromJson(json))
        .toList();

    // Lấy tất cả reaction cho các comment trong bài viết này
    if (allComments.isNotEmpty) {
      final commentIds = allComments.map((c) => c.id).toList();

      final reactions = await _supabase
          .from('comment_reactions')
          .select('comment_id, reaction_type, user_id')
          .inFilter('comment_id', commentIds);

      // Tạo map đếm like/dislike và reaction của user hiện tại
      final Map<String, int> likeCounts = {};
      final Map<String, int> dislikeCounts = {};
      final Map<String, String> userReactions = {};

      for (var r in reactions) {
        final commentId = r['comment_id'] as String;
        final type = r['reaction_type'] as String;
        final userId = r['user_id'] as String;

        if (type == 'like') {
          likeCounts[commentId] = (likeCounts[commentId] ?? 0) + 1;
        } else if (type == 'dislike') {
          dislikeCounts[commentId] = (dislikeCounts[commentId] ?? 0) + 1;
        }

        // Lưu reaction của user hiện tại
        if (currentUser != null && userId == currentUser.id) {
          userReactions[commentId] = type;
        }
      }

      // Gán vào từng comment
      for (var comment in allComments) {
        comment.likeCount = likeCounts[comment.id] ?? 0;
        comment.dislikeCount = dislikeCounts[comment.id] ?? 0;
        comment.myReaction = userReactions[comment.id];
      }
    }

    // Thuật toán xây dựng cây bình luận (Parent - Child)
    List<CommentModel> rootComments = [];
    Map<String, CommentModel> commentMap = {for (var c in allComments) c.id: c};

    for (var comment in allComments) {
      if (comment.parentId == null) {
        // Nếu không có parent_id thì là bình luận gốc
        rootComments.add(comment);
      } else {
        // Nếu có parent_id, tìm "cha" của nó và cho vào danh sách replies
        final parent = commentMap[comment.parentId];
        if (parent != null) {
          // Lưu ý: Chúng ta cần khởi tạo list replies là mảng rỗng trong Model
          parent.replies.add(comment);
        }
      }
    }

    // Đảo ngược để bình luận mới nhất hiện lên đầu
    return rootComments.reversed.toList();
  }

  // 2. Upload ảnh lên Cloudinary (Unsigned Upload)
  // Trả về URL ảnh đã host trên Cloudinary CDN
  Future<String?> uploadCommentImage(File imageFile) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ LỖI: Người dùng chưa đăng nhập');
        return null;
      }

      // 1. Kiểm tra đuôi file
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!allowedExtensions.contains(fileExtension)) {
        debugPrint(
          '❌ LỖI: Định dạng file không hỗ trợ. Hỗ trợ: $allowedExtensions',
        );
        return null;
      }

      // 2. Kiểm tra file tồn tại
      if (!await imageFile.exists()) {
        debugPrint('❌ LỖI: File không tồn tại: ${imageFile.path}');
        return null;
      }

      debugPrint('📤 Đang upload ảnh lên Cloudinary...');

      // 3. Gửi ảnh lên Cloudinary bằng Unsigned Upload
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final imageUrl = jsonData['secure_url'] as String;

        debugPrint('✅ UPLOAD CLOUDINARY THÀNH CÔNG: $imageUrl');
        return imageUrl;
      } else {
        debugPrint(
          '❌ CLOUDINARY LỖI (${response.statusCode}): ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ LỖI khi upload Cloudinary: $e');
      rethrow;
    }
  }

  // 3. Gửi bình luận mới (Hỗ trợ cả reply và ảnh)
  Future<void> postComment({
    required String articleUrl,
    required String content,
    String? imageUrl,
    String? parentId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('comments').insert({
      'article_url': articleUrl,
      'user_id': user.id,
      'user_name': user.userMetadata?['full_name'] ?? 'Người dùng',
      'user_avatar': user.userMetadata?['avatar_url'] ?? '',
      'content': content,
      'image_url': imageUrl,
      'parent_id': parentId,
    });
  }

  // 4. Toggle reaction (like/dislike) cho bình luận
  // Trả về: reaction_type mới (hoặc null nếu đã bỏ reaction)
  Future<String?> toggleReaction(String commentId, String reactionType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Kiểm tra user đã reaction comment này chưa
    final existing = await _supabase
        .from('comment_reactions')
        .select('id, reaction_type')
        .eq('comment_id', commentId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      // Chưa reaction → Thêm mới
      await _supabase.from('comment_reactions').insert({
        'comment_id': commentId,
        'user_id': user.id,
        'reaction_type': reactionType,
      });
      return reactionType;
    } else if (existing['reaction_type'] == reactionType) {
      // Đã reaction cùng loại → Bỏ reaction (toggle off)
      await _supabase
          .from('comment_reactions')
          .delete()
          .eq('id', existing['id']);
      return null;
    } else {
      // Đã reaction khác loại → Đổi sang loại mới
      await _supabase
          .from('comment_reactions')
          .update({'reaction_type': reactionType})
          .eq('id', existing['id']);
      return reactionType;
    }
  }
}
