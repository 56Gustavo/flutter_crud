class ImageItem {
  final String id;
  final String imageUrl;
  final String? description;
  bool isHovered = false;

  ImageItem({
    required this.id,
    required this.imageUrl,
    this.description,
  });
}
