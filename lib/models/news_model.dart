class NewsModel {
  final String title;
  final String articleUrl;
  final String imageUrl;
  final String publishedAt;
  final String? description;

  const NewsModel({
    required this.title,
    required this.articleUrl,
    required this.imageUrl,
    required this.publishedAt,
    this.description,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      articleUrl: json['article_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      publishedAt: json['published_at'] ?? '',
      description: json['description'],
    );
  }
}
