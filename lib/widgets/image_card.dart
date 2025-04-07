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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            if (item.description != null && item.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
