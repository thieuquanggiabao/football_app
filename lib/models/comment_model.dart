class CommentModel {
  final String id;
  final String articleUrl;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl; // Đường dẫn ảnh (nếu có)
  final String? parentId; // ID của bình luận gốc (nếu là câu trả lời)
  final DateTime createdAt;
  int likeCount;
  int dislikeCount;
  String? myReaction;
  List<CommentModel> replies; // Chứa danh sách các câu trả lời con

  CommentModel({
    required this.id,
    required this.articleUrl,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    this.parentId,
    required this.createdAt,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.myReaction,
    this.replies = const [],
  });

  // Chuyển đổi từ JSON (Supabase) sang Model
  factory CommentModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    return CommentModel(
      id: json['id'],
      articleUrl: json['article_url'],
      userId: json['user_id'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'] ?? '',
      content: json['content'],
      imageUrl: json['image_url'],
      parentId: json['parent_id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      // Các trường reaction sẽ được xử lý ở Repository hoặc qua truy vấn join
      likeCount: json['like_count'] ?? 0,
      dislikeCount: json['dislike_count'] ?? 0,
      myReaction: json['my_reaction'],
      replies: [], // Khởi tạo danh sách rỗng
    );
  }
}
