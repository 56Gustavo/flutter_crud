import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_item.dart';
import '../widgets/image_card.dart';
import 'package:uuid/uuid.dart';
import 'view_screen.dart';

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

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('images');
    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      setState(() {
        _images.addAll(decoded.map((e) => ImageItem.fromJson(e)));
      });
    }
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_images.map((e) => e.toJson()).toList());
    await prefs.setString('images', data);
  }

  void _addImageFromUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) return;
    setState(() {
      _images.add(ImageItem(
        id: uuid.v4(),
        imageUrl: url,
        description: null,
      ));
    });
    _saveImages();
    _urlController.clear();
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
          });
          _saveImages();
        });
      }
    });
  }

  List<ImageItem> get _filteredImages {
    if (_searchQuery.isEmpty) return _images;
    return _images.where((img) => img.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  void _navigateToViewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewScreen(images: _images)),
    );
  }

  void _editImage(ImageItem item, String newDescription) {
    setState(() {
      final index = _images.indexWhere((element) => element.id == item.id);
      _images[index] = ImageItem(
        id: item.id,
        imageUrl: item.imageUrl,
        description: newDescription,
      );
    });
    _saveImages();
  }

  void _deleteImage(String id) {
    setState(() {
      _images.removeWhere((img) => img.id == id);
    });
    _saveImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de Imagens'),
        actions: [
          IconButton(
            onPressed: _navigateToViewScreen,
            icon: const Icon(Icons.view_list, size: 28),
            tooltip: 'Visualizar Imagens',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: TextField(
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
                icon: const Icon(Icons.add_photo_alternate, size: 28),
                tooltip: 'Adicionar imagem do computador',
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
                    return ImageCard(
                      item: item,
                      onDelete: () => _deleteImage(item.id),
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            final controller = TextEditingController(text: item.description ?? '');
                            return AlertDialog(
                              title: const Text('Editar Descrição'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(labelText: 'Descrição'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _editImage(item, controller.text.trim());
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Salvar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
