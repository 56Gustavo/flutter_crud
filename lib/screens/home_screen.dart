import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import 'image_detail_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ImageItem> _images = [];
  final TextEditingController _urlController = TextEditingController();
  final uuid = const Uuid();
  String _searchQuery = '';


  void _pickImageFromDevice() {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final fileName = file.name.split('.').first;
          setState(() {
            _images.add(ImageItem(
              id: uuid.v4(),
              imageUrl: reader.result as String,
              description: fileName,
            ));
          });
        });
      }
    });
  }

  List<ImageItem> get _filteredImages {
    if (_searchQuery.isEmpty) return _images;
    return _images.where((img) => img.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  void _openDetail(ImageItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageDetailScreen(
          item: item,
          onUpdate: _updateImage,
          onDelete: _deleteImage,
        ),
      ),
    );
  }

  void _updateImage(ImageItem updated) {
    setState(() {
      final index = _images.indexWhere((img) => img.id == updated.id);
      if (index != -1) {
        _images[index] = updated;
      }
    });
  }

  void _deleteImage(String id) {
    setState(() {
      _images.removeWhere((img) => img.id == id);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria de Imagens')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      labelText: 'Buscar por descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                IconButton(
                  onPressed: _pickImageFromDevice,
                  icon: const Icon(Icons.add_photo_alternate),
                  tooltip: 'Adicionar do computador',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                  return GridView.builder(
                    itemCount: _filteredImages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (ctx, i) {
                      final item = _filteredImages[i];
                      return GestureDetector(
                        onTap: () => _openDetail(item),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
