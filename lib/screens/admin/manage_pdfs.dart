import 'package:flutter/material.dart';
import '../../models/content_file_model.dart';
import '../../services/database_service.dart';

class ManagePDFs extends StatefulWidget {
  const ManagePDFs({super.key});

  @override
  State<ManagePDFs> createState() => _ManagePDFsState();
}

class _ManagePDFsState extends State<ManagePDFs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _tabs = [
    {'label': 'LIMPIEZAS', 'category': 'limpieza', 'icon': Icons.water_drop_outlined, 'color': Colors.teal},
    {'label': 'RITUALES', 'category': 'ritual', 'icon': Icons.auto_fix_high_outlined, 'color': Colors.deepPurple},
    {'label': 'TAROT', 'category': 'tarot', 'icon': Icons.auto_awesome_outlined, 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR PDFs',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB71C1C),
          labelColor: const Color(0xFFB71C1C),
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
          tabs: _tabs
              .map((t) => Tab(
                    icon: Icon(t['icon'] as IconData, size: 18),
                    text: t['label'] as String,
                  ))
              .toList(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: _tabs
              .map((t) => _PDFCategoryTab(
                    category: t['category'] as String,
                    label: t['label'] as String,
                    color: t['color'] as Color,
                    icon: t['icon'] as IconData,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ─── Category Tab ─────────────────────────────────────────────────────────────

class _PDFCategoryTab extends StatelessWidget {
  final String category;
  final String label;
  final Color color;
  final IconData icon;

  const _PDFCategoryTab({
    required this.category,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ContentFileModel>>(
      stream: DatabaseService().streamContentByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
          );
        }

        final items = snapshot.data ?? [];

        return Column(
          children: [
            // Add button bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text('AGREGAR PDF DE $label'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(
                      icon: icon,
                      color: color,
                      label: label,
                      onAdd: () => _showAddDialog(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _PDFTile(
                          item: items[index],
                          color: color,
                          onEdit: () =>
                              _showEditDialog(context, items[index]),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _PDFDialog(category: category),
    );
  }

  void _showEditDialog(BuildContext context, ContentFileModel item) {
    showDialog(
      context: context,
      builder: (_) => _PDFDialog(category: category, item: item),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.icon,
    required this.color,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.4), size: 64),
          const SizedBox(height: 16),
          Text(
            'No hay PDFs de $label',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega el primer PDF usando el botón de arriba',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('AGREGAR PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PDF Tile ─────────────────────────────────────────────────────────────────

class _PDFTile extends StatelessWidget {
  final ContentFileModel item;
  final Color color;
  final VoidCallback onEdit;

  const _PDFTile({
    required this.item,
    required this.color,
    required this.onEdit,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        color: color.withOpacity(0.05),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Icon(Icons.picture_as_pdf_outlined, color: color, size: 22),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.description,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white38, size: 11),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.createdAt),
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.link, color: Colors.white38, size: 11),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.url,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFFB71C1C), size: 20),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red),
        ),
        title: const Text(
          '¿Eliminar PDF?',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminará "${item.title}" de la lista.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deleteContentFile(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

// ─── PDF Dialog (Add / Edit) ──────────────────────────────────────────────────

class _PDFDialog extends StatefulWidget {
  final String category;
  final ContentFileModel? item;

  const _PDFDialog({required this.category, this.item});

  @override
  State<_PDFDialog> createState() => _PDFDialogState();
}

class _PDFDialogState extends State<_PDFDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item?.title ?? '');
    _urlCtrl = TextEditingController(text: widget.item?.url ?? '');
    _descCtrl = TextEditingController(text: widget.item?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: Text(
        isEdit ? 'EDITAR PDF' : 'NUEVO PDF',
        style: const TextStyle(
            color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_titleCtrl, 'Título del PDF', Icons.title),
            const SizedBox(height: 12),
            _field(_urlCtrl, 'URL del PDF', Icons.link,
                keyboardType: TextInputType.url),
            const SizedBox(height: 12),
            _field(_descCtrl, 'Descripción (opcional)', Icons.description,
                maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'GUARDAR' : 'AGREGAR'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon:
            Icon(icon, color: const Color(0xFFB71C1C), size: 18),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título y la URL son obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final id = widget.item?.id ??
          '${widget.category}_${DateTime.now().millisecondsSinceEpoch}';
      final file = ContentFileModel(
        id: id,
        title: title,
        description: _descCtrl.text.trim(),
        url: url,
        category: widget.category,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      await DatabaseService().saveContentFile(file);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item != null ? 'PDF actualizado' : 'PDF agregado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
