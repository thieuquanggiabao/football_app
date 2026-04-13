import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentSection extends StatefulWidget {
  final String articleUrl;
  const CommentSection({super.key, required this.articleUrl});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentRepo = CommentRepository();
  final _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<CommentModel> _rootComments = [];
  bool _isLoading = true;
  bool _isUploading = false; // ← Thêm trạng thái upload

  // Trạng thái bổ sung
  File? _selectedImage;
  String? _replyingToId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  String _getRelativeTime(DateTime date) {
    return timeago.format(date, locale: 'vi');
  }

  Future<void> _loadComments() async {
    try {
      final data = await _commentRepo.getComments(widget.articleUrl);
      if (mounted) {
        setState(() {
          _rootComments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _handleSubmit() async {
    final content = _commentController.text.trim();
    // Cho phép gửi nếu có nội dung HOẶC có ảnh
    if (content.isEmpty && _selectedImage == null) return;

    try {
      setState(() => _isUploading = true); // ← Bắt đầu upload
      String? imageUrl;

      // Nếu người dùng có chọn ảnh
      if (_selectedImage != null) {
        debugPrint('📤 Đang bắt đầu upload ảnh...');
        try {
          imageUrl = await _commentRepo.uploadCommentImage(_selectedImage!);

          if (imageUrl == null) {
            debugPrint('❌ Upload ảnh thất bại');
            if (mounted) {
              setState(() => _isUploading = false); // ← Reset trạng thái
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Upload ảnh thất bại. Vui lòng thử lại.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return; // ← Dừng nếu upload thất bại
          }
        } on Exception catch (e) {
          debugPrint('❌ Lỗi upload: $e');
          if (mounted) {
            setState(() => _isUploading = false); // ← Reset trạng thái
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Lỗi: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      // Gửi dữ liệu vào bảng comments
      await _commentRepo.postComment(
        articleUrl: widget.articleUrl,
        content: content,
        imageUrl: imageUrl,
        parentId: _replyingToId,
      );

      if (mounted) {
        // Reset UI sau khi thành công
        _commentController.clear();
        setState(() {
          _selectedImage = null;
          _replyingToId = null;
          _replyingToName = null;
          _isUploading = false;
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bình luận đã được gửi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _loadComments(); // Tải lại danh sách
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi bình luận: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  // Xử lý thả cảm xúc (like/dislike) với cập nhật UI tức thì
  Future<void> _handleReaction(CommentModel comment, String type) async {
    debugPrint('👆 Nhấn $type cho comment: ${comment.id}');

    // Lưu trạng thái cũ để rollback nếu lỗi
    final oldReaction = comment.myReaction;
    final oldLikeCount = comment.likeCount;
    final oldDislikeCount = comment.dislikeCount;

    // Cập nhật UI ngay lập tức (Optimistic Update)
    setState(() {
      if (comment.myReaction == type) {
        // Toggle off: bỏ reaction
        comment.myReaction = null;
        if (type == 'like') comment.likeCount--;
        if (type == 'dislike') comment.dislikeCount--;
      } else {
        // Nếu đang có reaction khác → trừ cái cũ
        if (comment.myReaction == 'like') comment.likeCount--;
        if (comment.myReaction == 'dislike') comment.dislikeCount--;
        // Thêm reaction mới
        comment.myReaction = type;
        if (type == 'like') comment.likeCount++;
        if (type == 'dislike') comment.dislikeCount++;
      }
    });

    try {
      // Gọi API
      debugPrint('📡 Đang gọi API toggleReaction...');
      await _commentRepo.toggleReaction(comment.id, type);
      debugPrint('✅ Reaction thành công!');
    } catch (e) {
      debugPrint('❌ Reaction LỖI: $e');
      // Rollback nếu API lỗi
      if (mounted) {
        setState(() {
          comment.myReaction = oldReaction;
          comment.likeCount = oldLikeCount;
          comment.dislikeCount = oldDislikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget hiển thị từng item bình luận (Đệ quy)
  Widget _buildCommentItem(CommentModel comment, {double depth = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 12 + (depth.clamp(0, 3) * 24), // Thụt lề mỗi cấp, tối đa 3 cấp
            right: 12,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: comment.userAvatar.isNotEmpty
                    ? NetworkImage(comment.userAvatar)
                    : null,
                child: comment.userAvatar.isEmpty
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),

                    if (comment.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 150,
                            maxWidth: 150,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildCommentImage(comment.imageUrl!),
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Thời gian
                        Flexible(
                          child: Text(
                            _getRelativeTime(comment.createdAt),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nút Like
                        GestureDetector(
                          onTap: () => _handleReaction(comment, 'like'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.myReaction == 'like'
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 14,
                                color: comment.myReaction == 'like'
                                    ? Colors.greenAccent
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${comment.likeCount}',
                                style: TextStyle(
                                  color: comment.myReaction == 'like'
                                      ? Colors.greenAccent
                                      : Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Nút Dislike
                        GestureDetector(
                          onTap: () => _handleReaction(comment, 'dislike'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.myReaction == 'dislike'
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                size: 14,
                                color: comment.myReaction == 'dislike'
                                    ? Colors.redAccent
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${comment.dislikeCount}',
                                style: TextStyle(
                                  color: comment.myReaction == 'dislike'
                                      ? Colors.redAccent
                                      : Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Nút Trả lời (compact)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _replyingToId = comment.id;
                              _replyingToName = comment.userName;
                            });
                          },
                          child: const Text(
                            'Trả lời',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Render bình luận con
        if (comment.replies.isNotEmpty)
          ...comment.replies
              .map((reply) => _buildCommentItem(reply, depth: depth + 1))
              .toList(),
      ],
    );
  }

  // Widget hiển thị ảnh bình luận (hỗ trợ cả Base64 và URL mạng)
  Widget _buildCommentImage(String imageUrl) {
    // Nếu là Base64 data URI (data:image/...;base64,...)
    if (imageUrl.startsWith('data:')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.white54),
        );
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.white54);
      }
    }

    // Nếu là URL mạng thông thường
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.error, color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Để giữ nền của BottomSheet
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '💬 Bình luận',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  )
                : ListView.builder(
                    itemCount: _rootComments.length,
                    itemBuilder: (context, index) =>
                        _buildCommentItem(_rootComments[index]),
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: Colors.grey[900],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToId != null)
            Container(
              color: Colors.greenAccent.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Đang trả lời $_replyingToName',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToId = null),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedImage!, height: 80),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: _isUploading
                          ? null
                          : () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.greenAccent),
                  onPressed: _isUploading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.greenAccent),
                  onPressed: _isUploading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    enabled: !_isUploading, // ← Vô hiệu hóa khi uploading
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.greenAccent,
                            ),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.greenAccent),
                  onPressed: _isUploading ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
