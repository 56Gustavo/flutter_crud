import 'dart:html' as html;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    final imagesJson = _images.map((img) => jsonEncode({
          'id': img.id,
          'imageUrl': img.imageUrl,
          'description': img.description,
        })).toList();
    await prefs.setStringList('images', imagesJson);
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final imagesJson = prefs.getStringList('images') ?? [];
    setState(() {
      _images.clear();
      _images.addAll(imagesJson.map((img) {
        final data = jsonDecode(img);
        return ImageItem(
          id: data['id'],
          imageUrl: data['imageUrl'],
          description: data['description'],
        );
      }).toList());
    });
  }

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
            _saveImages();
          });
        });
      }
    });
  }

  List<ImageItem> get _filteredImages {
    final sortedImages = List<ImageItem>.from(_images.reversed);
    if (_searchQuery.isEmpty) return sortedImages;
    return sortedImages.where((img) => img.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
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
    _saveImages();
  }

  void _deleteImage(String id) {
    setState(() {
      _images.removeWhere((img) => img.id == id);
    });
    _saveImages();
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
                SizedBox(
                  height: 50,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() {}),
                    onTapUp: (_) => setState(() {}),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.grey, Colors.blueGrey],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromDevice,
                        icon: const Icon(Icons.add_photo_alternate, size: 26),
                        label: const Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 17),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      labelText: 'Buscar por descrição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _filteredImages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 4 / 5,
                    ),
                    itemBuilder: (ctx, i) {
                      final item = _filteredImages[i];
                      return GestureDetector(
                        onTap: () => _openDetail(item),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => item.isHovered = true),
                          onExit: (_) => setState(() => item.isHovered = false),
                          child: Card(
                            elevation: item.isHovered ? 55 : 10, 
                            shadowColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70),
                                    ),
                                  ),
                              ],
                            ),
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
