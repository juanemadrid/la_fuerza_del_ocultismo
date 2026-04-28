import 'package:flutter/material.dart';
import '../../models/content_file_model.dart';
import '../../services/database_service.dart';

class ManagePDFs extends StatefulWidget {
  const ManagePDFs({super.key});

  @override
  State<ManagePDFs> createState() => _ManagePDFsState();
}

class _ManagePDFsState extends State<ManagePDFs> {
  final DatabaseService _db = DatabaseService();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'limpieza';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GESTIONAR PDFs')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: ['limpieza', 'ritual', 'tarot'].map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'URL del PDF')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveContent,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
              child: const Text('SUBIR CONTENIDO'),
            ),
            const Divider(height: 40),
            Expanded(
              child: StreamBuilder<List<ContentFileModel>>(
                stream: _db.streamContentByCategory(_selectedCategory),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _db.deleteContentFile(item.id),
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

  void _saveContent() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) return;

    final content = ContentFileModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      url: _urlController.text,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    await _db.saveContentFile(content);
    _titleController.clear();
    _urlController.clear();
    _descController.clear();
  }
}
