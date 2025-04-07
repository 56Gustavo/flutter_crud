import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageCard extends StatelessWidget {
  final ImageItem item;
  final VoidCallback onTap;

  const ImageCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            if (item.description != null && item.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
