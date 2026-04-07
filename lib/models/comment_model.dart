class CommentModel {
  final String id;
  final String articleUrl;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.articleUrl,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      articleUrl: json['article_url'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Fan Bóng Đá',
      userAvatar: json['user_avatar'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
