class Photo {
  final String id;
  final String name;
  final String url;
  final String? thumbnailUrl;

  Photo({
    required this.id,
    required this.name,
    required this.url,
    this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      name: json['name'] ?? 'Untitled',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
