import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageDetailScreen extends StatefulWidget {
  final ImageItem item;
  final void Function(ImageItem) onUpdate;
  final void Function(String) onDelete;

  const ImageDetailScreen({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late ImageItem _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  void _editDescription(BuildContext context) {
    final controller = TextEditingController(text: _currentItem.description ?? '');
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
                id: _currentItem.id,
                imageUrl: _currentItem.imageUrl,
                description: controller.text.trim(),
              );
              widget.onUpdate(updated);
              setState(() {
                _currentItem = updated;
              });
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
            icon: const Icon(Icons.edit_note),
            onPressed: () => _editDescription(context),
            tooltip: 'Editar Descrição',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => widget.onDelete(_currentItem.id),
            tooltip: 'Excluir Imagem',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.grey[900]!.withOpacity(0.6)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _currentItem.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_currentItem.description != null && _currentItem.description!.isNotEmpty)
            Container(
              key: ValueKey(_currentItem.description),
              color: Colors.grey[850],
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _currentItem.description!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
