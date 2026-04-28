class ContentFileModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String category; // 'limpieza', 'ritual', etc.
  final DateTime createdAt;

  ContentFileModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.category,
    required this.createdAt,
  });

  factory ContentFileModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentFileModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'category': category,
      'createdAt': createdAt,
    };
  }
}
