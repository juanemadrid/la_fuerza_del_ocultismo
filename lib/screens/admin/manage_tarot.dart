import 'package:flutter/material.dart';
import '../../models/tarot_card_model.dart';
import '../../services/database_service.dart';

class ManageTarot extends StatelessWidget {
  const ManageTarot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR TAROT',
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
            tooltip: 'Agregar carta',
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
        child: StreamBuilder<List<TarotCardModel>>(
          stream: DatabaseService().streamTarotCards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final cards = snapshot.data ?? [];

            if (cards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_outlined,
                        color: Color(0xFFB71C1C), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay cartas configuradas',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca + para agregar cartas de tarot',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _cargarCartasDefault(context),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('CARGAR CARTAS PREDETERMINADAS'),
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
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return _CartaTile(
                  card: card,
                  onEdit: () => _mostrarDialogo(context, card),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, TarotCardModel? card) {
    showDialog(
      context: context,
      builder: (_) => _CartaDialog(card: card),
    );
  }

  Future<void> _cargarCartasDefault(BuildContext context) async {
    final db = DatabaseService();
    final cartasDefault = [
      {'nombre': 'El Loco', 'significado': 'Nuevos comienzos, espontaneidad, fe en el futuro', 'orden': 0},
      {'nombre': 'El Mago', 'significado': 'Manifestación, recursos, poder, acción inspirada', 'orden': 1},
      {'nombre': 'La Sacerdotisa', 'significado': 'Intuición, misterio, subconsciente', 'orden': 2},
      {'nombre': 'La Emperatriz', 'significado': 'Feminidad, belleza, naturaleza, abundancia', 'orden': 3},
      {'nombre': 'El Emperador', 'significado': 'Autoridad, estructura, control, padre', 'orden': 4},
      {'nombre': 'El Hierofante', 'significado': 'Tradición, conformidad, moralidad, ética', 'orden': 5},
      {'nombre': 'Los Enamorados', 'significado': 'Amor, armonía, relaciones, valores', 'orden': 6},
      {'nombre': 'El Carro', 'significado': 'Control, voluntad, victoria, determinación', 'orden': 7},
      {'nombre': 'La Fuerza', 'significado': 'Fuerza interior, coraje, paciencia, compasión', 'orden': 8},
      {'nombre': 'El Ermitaño', 'significado': 'Búsqueda interior, introspección, guía', 'orden': 9},
      {'nombre': 'La Rueda de la Fortuna', 'significado': 'Cambio, ciclos, destino, punto de inflexión', 'orden': 10},
      {'nombre': 'La Justicia', 'significado': 'Justicia, equidad, verdad, ley', 'orden': 11},
      {'nombre': 'El Colgado', 'significado': 'Pausa, rendición, dejar ir, nueva perspectiva', 'orden': 12},
      {'nombre': 'La Muerte', 'significado': 'Finales, transformación, transición, liberación', 'orden': 13},
      {'nombre': 'La Templanza', 'significado': 'Balance, moderación, paciencia, propósito', 'orden': 14},
      {'nombre': 'El Diablo', 'significado': 'Ataduras, adicción, materialismo, ignorancia', 'orden': 15},
      {'nombre': 'La Torre', 'significado': 'Cambio repentino, revelación, despertar', 'orden': 16},
      {'nombre': 'La Estrella', 'significado': 'Esperanza, fe, renovación, espiritualidad', 'orden': 17},
      {'nombre': 'La Luna', 'significado': 'Ilusión, miedo, ansiedad, subconsciente', 'orden': 18},
      {'nombre': 'El Sol', 'significado': 'Alegría, éxito, celebración, positividad', 'orden': 19},
      {'nombre': 'El Juicio', 'significado': 'Juicio, renacimiento, perdón, llamado interior', 'orden': 20},
      {'nombre': 'El Mundo', 'significado': 'Completitud, logro, viaje, cumplimiento', 'orden': 21},
    ];

    for (final c in cartasDefault) {
      final card = TarotCardModel(
        id: 'carta_${c['orden']}',
        nombre: c['nombre'] as String,
        significado: c['significado'] as String,
        orden: c['orden'] as int,
      );
      await db.saveTarotCard(card);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('22 cartas cargadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _CartaTile extends StatelessWidget {
  final TarotCardModel card;
  final VoidCallback onEdit;

  const _CartaTile({required this.card, required this.onEdit});

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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB71C1C)),
          ),
          child: Center(
            child: Text(
              '${card.orden + 1}',
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          card.nombre,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          card.significado,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
        title: const Text('¿Eliminar carta?', style: TextStyle(color: Colors.red)),
        content: Text(
          'Se eliminará "${card.nombre}" del mazo.',
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
              await DatabaseService().deleteTarotCard(card.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _CartaDialog extends StatefulWidget {
  final TarotCardModel? card;
  const _CartaDialog({this.card});

  @override
  State<_CartaDialog> createState() => _CartaDialogState();
}

class _CartaDialogState extends State<_CartaDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _significadoCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _ordenCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.card?.nombre ?? '');
    _significadoCtrl = TextEditingController(text: widget.card?.significado ?? '');
    _descripcionCtrl = TextEditingController(text: widget.card?.descripcionExtendida ?? '');
    _ordenCtrl = TextEditingController(text: '${widget.card?.orden ?? 0}');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _significadoCtrl.dispose();
    _descripcionCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.card != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: Text(
        isEdit ? 'EDITAR CARTA' : 'NUEVA CARTA',
        style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nombreCtrl, 'Nombre de la carta'),
            const SizedBox(height: 12),
            _field(_significadoCtrl, 'Significado breve', maxLines: 2),
            const SizedBox(height: 12),
            _field(_descripcionCtrl, 'Descripción extendida (opcional)', maxLines: 4),
            const SizedBox(height: 12),
            _field(_ordenCtrl, 'Orden (número)', keyboardType: TextInputType.number),
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
    if (_nombreCtrl.text.trim().isEmpty || _significadoCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final id = widget.card?.id ??
        'carta_${DateTime.now().millisecondsSinceEpoch}';
    final card = TarotCardModel(
      id: id,
      nombre: _nombreCtrl.text.trim(),
      significado: _significadoCtrl.text.trim(),
      descripcionExtendida: _descripcionCtrl.text.trim(),
      orden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
    );

    await DatabaseService().saveTarotCard(card);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.card != null ? 'Carta actualizada' : 'Carta creada'),
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
    }
  }
}
