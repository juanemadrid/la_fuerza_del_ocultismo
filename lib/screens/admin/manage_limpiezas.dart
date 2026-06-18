import 'package:flutter/material.dart';
import '../../models/limpieza_model.dart';
import '../../services/database_service.dart';

class ManageLimpiezas extends StatelessWidget {
  const ManageLimpiezas({super.key});

  static const List<String> _categorias = [
    'cuerpo', 'alma', 'espíritu', 'negocios',
    'casa', 'lotes', 'propiedad', 'vehículos', 'otro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR LIMPIEZAS',
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
            tooltip: 'Agregar limpieza',
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
        child: StreamBuilder<List<LimpiezaModel>>(
          stream: DatabaseService().streamLimpiezas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final limpiezas = snapshot.data ?? [];

            if (limpiezas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop_outlined,
                        color: Color(0xFFB71C1C), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay limpiezas configuradas',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca + para agregar una limpieza',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _cargarLimpiezasDefault(context),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('CARGAR LIMPIEZAS PREDETERMINADAS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: limpiezas.length,
              itemBuilder: (context, index) {
                final limpieza = limpiezas[index];
                return _LimpiezaTile(
                  limpieza: limpieza,
                  onEdit: () => _mostrarDialogo(context, limpieza),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, LimpiezaModel? limpieza) {
    showDialog(
      context: context,
      builder: (_) => _LimpiezaDialog(limpieza: limpieza),
    );
  }

  Future<void> _cargarLimpiezasDefault(BuildContext context) async {
    final db = DatabaseService();
    final defaults = [
      {'nombre': 'Limpieza de Cuerpo', 'descripcion': 'Purificación energética del cuerpo físico', 'categoria': 'cuerpo', 'duracion': '1 hora', 'orden': 0},
      {'nombre': 'Limpieza de Alma', 'descripcion': 'Sanación profunda del alma y emociones', 'categoria': 'alma', 'duracion': '2 horas', 'orden': 1},
      {'nombre': 'Limpieza de Espíritu', 'descripcion': 'Liberación de energías negativas del espíritu', 'categoria': 'espíritu', 'duracion': '1.5 horas', 'orden': 2},
      {'nombre': 'Limpieza de Negocios', 'descripcion': 'Atracción de prosperidad y éxito empresarial', 'categoria': 'negocios', 'duracion': '2 horas', 'orden': 3},
      {'nombre': 'Limpieza de Casa', 'descripcion': 'Purificación del hogar y sus energías', 'categoria': 'casa', 'duracion': '3 horas', 'orden': 4},
      {'nombre': 'Limpieza de Lotes', 'descripcion': 'Limpieza energética de terrenos y lotes', 'categoria': 'lotes', 'duracion': '2 horas', 'orden': 5},
      {'nombre': 'Limpieza de Propiedad', 'descripcion': 'Purificación de propiedades y bienes raíces', 'categoria': 'propiedad', 'duracion': '3 horas', 'orden': 6},
      {'nombre': 'Limpieza de Vehículos', 'descripcion': 'Protección y limpieza energética de vehículos', 'categoria': 'vehículos', 'duracion': '1 hora', 'orden': 7},
    ];

    for (final l in defaults) {
      final limpieza = LimpiezaModel(
        id: 'limpieza_${l['orden']}',
        nombre: l['nombre'] as String,
        descripcion: l['descripcion'] as String,
        categoria: l['categoria'] as String,
        duracion: l['duracion'] as String,
        orden: l['orden'] as int,
      );
      await db.saveLimpieza(limpieza);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('8 limpiezas cargadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _LimpiezaTile extends StatelessWidget {
  final LimpiezaModel limpieza;
  final VoidCallback onEdit;

  const _LimpiezaTile({required this.limpieza, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.3)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB71C1C)),
          ),
          child: const Icon(Icons.water_drop_outlined,
              color: Color(0xFFB71C1C), size: 20),
        ),
        title: Text(
          limpieza.nombre,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              limpieza.descripcion,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (limpieza.duracion.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFFB71C1C), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    limpieza.duracion,
                    style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  if (limpieza.categoria.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        limpieza.categoria.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFB71C1C), size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
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
        title: const Text('¿Eliminar limpieza?', style: TextStyle(color: Colors.red)),
        content: Text(
          'Se eliminará "${limpieza.nombre}".',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deleteLimpieza(limpieza.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _LimpiezaDialog extends StatefulWidget {
  final LimpiezaModel? limpieza;
  const _LimpiezaDialog({this.limpieza});

  @override
  State<_LimpiezaDialog> createState() => _LimpiezaDialogState();
}

class _LimpiezaDialogState extends State<_LimpiezaDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _instruccionesCtrl;
  late TextEditingController _duracionCtrl;
  late TextEditingController _ordenCtrl;
  late String _categoria;
  bool _saving = false;

  static const List<String> _categorias = [
    'cuerpo', 'alma', 'espíritu', 'negocios',
    'casa', 'lotes', 'propiedad', 'vehículos', 'otro',
  ];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.limpieza?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: widget.limpieza?.descripcion ?? '');
    _instruccionesCtrl = TextEditingController(text: widget.limpieza?.instrucciones ?? '');
    _duracionCtrl = TextEditingController(text: widget.limpieza?.duracion ?? '');
    _ordenCtrl = TextEditingController(text: '${widget.limpieza?.orden ?? 0}');
    _categoria = widget.limpieza?.categoria ?? 'cuerpo';
    if (!_categorias.contains(_categoria)) _categoria = 'cuerpo';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _instruccionesCtrl.dispose();
    _duracionCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.limpieza != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: Text(
        isEdit ? 'EDITAR LIMPIEZA' : 'NUEVA LIMPIEZA',
        style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nombreCtrl, 'Nombre'),
            const SizedBox(height: 12),
            _field(_descripcionCtrl, 'Descripción breve', maxLines: 2),
            const SizedBox(height: 12),
            _field(_instruccionesCtrl, 'Instrucciones detalladas (opcional)', maxLines: 4),
            const SizedBox(height: 12),
            _field(_duracionCtrl, 'Duración (ej: 1 hora)'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoria,
              dropdownColor: const Color(0xFF1A1A1A),
              decoration: const InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                filled: true,
                fillColor: Color(0x0DFFFFFF),
              ),
              items: _categorias.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              )).toList(),
              onChanged: (val) => setState(() => _categoria = val!),
            ),
            const SizedBox(height: 12),
            _field(_ordenCtrl, 'Orden', keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'GUARDAR' : 'CREAR'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {int maxLines = 1, TextInputType? keyboardType}) {
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
    if (_nombreCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final id = widget.limpieza?.id ??
        'limpieza_${DateTime.now().millisecondsSinceEpoch}';
    final limpieza = LimpiezaModel(
      id: id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      instrucciones: _instruccionesCtrl.text.trim(),
      duracion: _duracionCtrl.text.trim(),
      categoria: _categoria,
      orden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
    );

    await DatabaseService().saveLimpieza(limpieza);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.limpieza != null ? 'Limpieza actualizada' : 'Limpieza creada'),
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
    }
  }
}
