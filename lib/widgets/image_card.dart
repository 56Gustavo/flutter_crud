import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../screens/image_detail_screen.dart';

class ImageCard extends StatelessWidget {
  final ImageItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ImageCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (_) => ImageDetailScreen(imageUrl: item.imageUrl),
          )
        );
      },
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
                child: Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            )
          ],
        ),
      ),
    );
  }
}
