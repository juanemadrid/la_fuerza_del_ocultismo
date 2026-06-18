import 'package:flutter/material.dart';
import '../../models/ritual_model.dart';
import '../../services/database_service.dart';

class ManageRituales extends StatelessWidget {
  const ManageRituales({super.key});

  static const List<String> _tipos = [
    'sanación',
    'abre caminos',
    'atracción',
    'dinero',
    'trabajo',
    'energías',
    'vecinos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR RITUALES',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB71C1C)),
            tooltip: 'Agregar ritual',
            onPressed: () => _mostrarDialogo(context, null),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: StreamBuilder<List<RitualModel>>(
          stream: DatabaseService().streamRituales(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final rituales = snapshot.data ?? [];

            if (rituales.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_fix_high_outlined,
                      color: Colors.deepPurple,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay rituales configurados',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca + para agregar un ritual',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarDialogo(context, null),
                      icon: const Icon(Icons.add),
                      label: const Text('AGREGAR RITUAL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rituales.length,
              itemBuilder: (context, index) {
                final ritual = rituales[index];
                return _RitualTile(
                  ritual: ritual,
                  onEdit: () => _mostrarDialogo(context, ritual),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, RitualModel? ritual) {
    showDialog(
      context: context,
      builder: (_) => _RitualDialog(ritual: ritual),
    );
  }
}

// ─── Ritual Tile ──────────────────────────────────────────────────────────────

class _RitualTile extends StatelessWidget {
  final RitualModel ritual;
  final VoidCallback onEdit;

  const _RitualTile({required this.ritual, required this.onEdit});

  Color _tipoColor(String tipo) {
    switch (tipo) {
      case 'sanación':
        return Colors.green;
      case 'abre caminos':
        return Colors.amber;
      case 'atracción':
        return Colors.pink;
      case 'dinero':
        return Colors.teal;
      case 'trabajo':
        return Colors.blue;
      case 'energías':
        return Colors.orange;
      case 'vecinos':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tipoColor(ritual.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.deepPurple),
          ),
          child: const Icon(
            Icons.auto_fix_high_outlined,
            color: Colors.deepPurple,
            size: 20,
          ),
        ),
        title: Text(
          ritual.nombre,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ritual.descripcion,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                ritual.tipo.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
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
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              onPressed: () => _confirmarEliminar(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red),
        ),
        title: const Text(
          '¿Eliminar ritual?',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminará "${ritual.nombre}".',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deleteRitual(ritual.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ritual eliminado'),
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

// ─── Ritual Dialog ────────────────────────────────────────────────────────────

class _RitualDialog extends StatefulWidget {
  final RitualModel? ritual;
  const _RitualDialog({this.ritual});

  @override
  State<_RitualDialog> createState() => _RitualDialogState();
}

class _RitualDialogState extends State<_RitualDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _instruccionesCtrl;
  late TextEditingController _ordenCtrl;
  late String _tipo;
  bool _saving = false;

  static const List<String> _tipos = [
    'sanación',
    'abre caminos',
    'atracción',
    'dinero',
    'trabajo',
    'energías',
    'vecinos',
  ];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.ritual?.nombre ?? '');
    _descripcionCtrl =
        TextEditingController(text: widget.ritual?.descripcion ?? '');
    _instruccionesCtrl =
        TextEditingController(text: widget.ritual?.instrucciones ?? '');
    _ordenCtrl =
        TextEditingController(text: '${widget.ritual?.orden ?? 0}');
    _tipo = widget.ritual?.tipo ?? 'sanación';
    if (!_tipos.contains(_tipo)) _tipo = 'sanación';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _instruccionesCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ritual != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: Text(
        isEdit ? 'EDITAR RITUAL' : 'NUEVO RITUAL',
        style: const TextStyle(
            color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nombreCtrl, 'Nombre del ritual'),
            const SizedBox(height: 12),
            _field(_descripcionCtrl, 'Descripción breve', maxLines: 2),
            const SizedBox(height: 12),
            _field(_instruccionesCtrl, 'Instrucciones detalladas (opcional)',
                maxLines: 4),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              dropdownColor: const Color(0xFF1A1A1A),
              decoration: const InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C)),
                ),
                filled: true,
                fillColor: Color(0x0DFFFFFF),
              ),
              items: _tipos
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _tipo = val!),
            ),
            const SizedBox(height: 12),
            _field(_ordenCtrl, 'Orden',
                keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR',
              style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'GUARDAR' : 'CREAR'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
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

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre es obligatorio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final id = widget.ritual?.id ??
        'ritual_${DateTime.now().millisecondsSinceEpoch}';
    final ritual = RitualModel(
      id: id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      instrucciones: _instruccionesCtrl.text.trim(),
      tipo: _tipo,
      orden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
    );

    try {
      await DatabaseService().saveRitual(ritual);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.ritual != null
                ? 'Ritual actualizado'
                : 'Ritual creado'),
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
