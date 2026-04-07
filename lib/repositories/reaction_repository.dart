import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

/// Kết quả trả về khi load reaction của một bài báo
class ReactionResult {
  final int likeCount;
  final int dislikeCount;
  final String? myReaction; // 'LIKE', 'DISLIKE', hoặc null

  const ReactionResult({
    required this.likeCount,
    required this.dislikeCount,
    this.myReaction,
  });
}

class ReactionRepository {
  /// Lấy số lượng Like/Dislike và trạng thái phản ứng của user hiện tại
  Future<ReactionResult> getReactions(
    String articleUrl,
    String? userId,
  ) async {
    // Đếm Like
    final likeRes = await supabase
        .from('article_reactions')
        .select('id')
        .eq('article_url', articleUrl)
        .eq('reaction_type', 'LIKE')
        .count(CountOption.exact);

    // Đếm Dislike
    final dislikeRes = await supabase
        .from('article_reactions')
        .select('id')
        .eq('article_url', articleUrl)
        .eq('reaction_type', 'DISLIKE')
        .count(CountOption.exact);

    // Kiểm tra phản ứng của user hiện tại
    String? myReaction;
    if (userId != null) {
      final myRes = await supabase
          .from('article_reactions')
          .select('reaction_type')
          .eq('article_url', articleUrl)
          .eq('user_id', userId)
          .maybeSingle();
      if (myRes != null) myReaction = myRes['reaction_type'];
    }

    return ReactionResult(
      likeCount: likeRes.count,
      dislikeCount: dislikeRes.count,
      myReaction: myReaction,
    );
  }

  /// Thêm hoặc đổi reaction (upsert)
  Future<void> upsertReaction({
    required String articleUrl,
    required String userId,
    required String reactionType,
  }) async {
    await supabase.from('article_reactions').upsert(
      {
        'article_url': articleUrl,
        'user_id': userId,
        'reaction_type': reactionType,
      },
      onConflict: 'article_url,user_id',
    );
  }

  /// Xóa reaction (hủy)
  Future<void> deleteReaction({
    required String articleUrl,
    required String userId,
  }) async {
    await supabase
        .from('article_reactions')
        .delete()
        .eq('article_url', articleUrl)
        .eq('user_id', userId);
  }
}
