import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ViewScreen extends StatelessWidget {
  final List<ImageItem> images;

  const ViewScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Imagens')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (ctx, i) {
          final item = images[i];
          return Card(
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
              ],
            ),
          );
        },
      ),
    );
  }
}
