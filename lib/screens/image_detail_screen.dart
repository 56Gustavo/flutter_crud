import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageDetailScreen extends StatelessWidget {
  final ImageItem item;
  final void Function(ImageItem) onUpdate;
  final void Function(String) onDelete;

  const ImageDetailScreen({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  void _editDescription(BuildContext context) {
    final controller = TextEditingController(text: item.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Descrição'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updated = ImageItem(
                id: item.id,
                imageUrl: item.imageUrl,
                description: controller.text.trim(),
              );
              onUpdate(updated);
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Imagem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editDescription(context),
            tooltip: 'Editar Descrição',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(item.id),
            tooltip: 'Excluir Imagem',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(item.imageUrl),
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                item.description!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
