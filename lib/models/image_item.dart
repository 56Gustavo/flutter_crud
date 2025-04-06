class ImageItem {
  final String id;
  final String imageUrl;
  final String? description;

  ImageItem({required this.id, required this.imageUrl, this.description});

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory ImageItem.fromJson(Map<String, dynamic> json) => ImageItem(
        id: json['id'],
        imageUrl: json['imageUrl'],
        description: json['description'],
      );
}
