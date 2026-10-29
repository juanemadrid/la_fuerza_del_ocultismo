import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tarot_card_model.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

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
      {'nombre': 'El Loco', 'significado': 'Nuevos comienzos, espontaneidad, fe en el camino y libertad de espíritu.', 'orden': 0},
      {'nombre': 'El Mago', 'significado': 'Poder personal, iniciativa, concentración y la manifestación de tus deseos.', 'orden': 1},
      {'nombre': 'La Sacerdotisa', 'significado': 'Intuición, misterio, sabiduría interior y el plano espiritual.', 'orden': 2},
      {'nombre': 'La Emperatriz', 'significado': 'Abundancia, creatividad, fertilidad, naturaleza y plenitud.', 'orden': 3},
      {'nombre': 'El Sacerdote', 'significado': 'Sabiduría tradicional, enseñanza, guía espiritual y valores establecidos.', 'orden': 4},
      {'nombre': 'El Amor', 'significado': 'Elecciones importantes, amor, alineación de valores y relaciones.', 'orden': 5},
      {'nombre': 'El Ermitaño', 'significado': 'Introspección, soledad buscada, reflexión y autodescubrimiento.', 'orden': 6},
      {'nombre': 'La Rueda de la Fortuna', 'significado': 'Cambio, ciclos, destino y puntos de inflexión inesperados.', 'orden': 7},
      {'nombre': 'La Fuerza', 'significado': 'Coraje, paciencia, compasión y control sobre los impulsos.', 'orden': 8},
      {'nombre': 'La Muerte', 'significado': 'Finales necesarios, transformación profunda, transición y liberación.', 'orden': 9},
      {'nombre': 'La Torre', 'significado': 'Cambio repentino, revelación, despertar espiritual y liberación de ilusiones.', 'orden': 10},
      {'nombre': 'El Mundo', 'significado': 'Completitud, logro supremo, viaje completado e integración.', 'orden': 11},
      {'nombre': 'El Bufón', 'significado': 'Diversión, ingenio, ironía y ver la vida desde otra perspectiva.', 'orden': 12},
      {'nombre': 'El Camino', 'significado': 'Dirección, elecciones de vida, sendero evolutivo y destino.', 'orden': 13},
      {'nombre': 'El Duende', 'significado': 'Travesura, suerte inesperada, conexión con la naturaleza y magia elemental.', 'orden': 14},
      {'nombre': 'El Miedo', 'significado': 'Bloqueos mentales, temores inconscientes y la necesidad de superarse.', 'orden': 15},
      {'nombre': 'El Perdón', 'significado': 'Liberación de resentimientos, paz interior y sanación emocional.', 'orden': 16},
      {'nombre': 'El Rey', 'significado': 'Liderazgo, control, estabilidad, sabiduría y protección.', 'orden': 17},
      {'nombre': 'El Viaje', 'significado': 'Movimiento, exploración, cambio de perspectiva y crecimiento personal.', 'orden': 18},
      {'nombre': 'Gran Premio', 'significado': 'Recompensa merecida, abundancia, éxito rotundo y fortuna.', 'orden': 19},
      {'nombre': 'La Bruja', 'significado': 'Magia práctica, intuición profunda, conexión con lo sagrado femenino y sabiduría.', 'orden': 20},
      {'nombre': 'La Envidia', 'significado': 'Celos, energías discordantes externas o internas, y la necesidad de autovaloración.', 'orden': 21},
      {'nombre': 'La Ira', 'significado': 'Pasión desbordada, enojo acumulado y necesidad de transmutación.', 'orden': 22},
      {'nombre': 'La Pobreza', 'significado': 'Mentalidad de escasez, dificultades temporales y necesidad de apoyo.', 'orden': 23},
      {'nombre': 'La Reina', 'significado': 'Poder receptivo, intuición, empatía, madurez emocional y soberanía.', 'orden': 24},
      {'nombre': 'La Traición', 'significado': 'Decepción, deslealtad, cortes dolorosos y aprendizaje de la confianza.', 'orden': 25},
      {'nombre': 'Negocios', 'significado': 'Acuerdos comerciales, transacciones, alianzas de trabajo y éxito financiero.', 'orden': 26},
      {'nombre': 'Oro', 'significado': 'Riqueza material, valor intrínseco, éxito sólido y prosperidad.', 'orden': 27},
      {'nombre': 'Plata', 'significado': 'Claridad mental, intuición, valor emocional y adaptabilidad.', 'orden': 28},
      {'nombre': 'Reconciliación', 'significado': 'Unión de opuestos, sanación de relaciones, paz y armonía recobrada.', 'orden': 29},
      {'nombre': 'Salud', 'significado': 'Bienestar físico, mental y espiritual, vitalidad y equilibrio orgánico.', 'orden': 30},
      {'nombre': 'Sorpresa', 'significado': 'Eventos inesperados, regalos del destino y giros del destino.', 'orden': 31},
      {'nombre': 'Suerte', 'significado': 'Buena fortuna, sincronicidades favorables y viento a favor.', 'orden': 32},
      {'nombre': 'Trabajo', 'significado': 'Esfuerzo constante, dedicación, desarrollo profesional y labor diaria.', 'orden': 33},
      {'nombre': 'Ángel', 'significado': 'Protección divina, guía celestial, pureza y mensajes de paz.', 'orden': 34},
      {'nombre': 'Carta Negra', 'significado': 'Energías densas, advertencia, autoanálisis profundo y cautela.', 'orden': 35},
      {'nombre': 'Carta Blanca', 'significado': 'Posibilidades infinitas, destino libre y poder de elección total.', 'orden': 36},
      {'nombre': 'Dinero', 'significado': 'Flujo financiero, ingresos, transacciones económicas y seguridad material.', 'orden': 37},
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
        SnackBar(
          content: Text('${cartasDefault.length} cartas cargadas exitosamente'),
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
          width: 36,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.5), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                ? Image.network(
                    card.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/tarot/carta_${card.orden}.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/tarot/carta_${card.orden}.png',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          '#${card.orden} — ${card.nombre}',
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
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  
  File? _imageFile;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.card?.nombre ?? '');
    _significadoCtrl = TextEditingController(text: widget.card?.significado ?? '');
    _descripcionCtrl = TextEditingController(text: widget.card?.descripcionExtendida ?? '');
    _ordenCtrl = TextEditingController(text: '${widget.card?.orden ?? 0}');
    _currentImageUrl = widget.card?.imageUrl;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _significadoCtrl.dispose();
    _descripcionCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
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
            // Preview de Imagen
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.5), width: 1.5),
                  color: Colors.white.withOpacity(0.03),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white30,
                                size: 40,
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: Colors.white38, size: 32),
                              SizedBox(height: 6),
                              Text(
                                'Añadir Imagen',
                                style: TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),
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
              : Text(isEdit ? 'GUARDAR' : 'CREAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        
    String? finalImageUrl = _currentImageUrl;
    if (_imageFile != null) {
      finalImageUrl = await StorageService().uploadTarotImage(_imageFile!, id);
    }

    final card = TarotCardModel(
      id: id,
      nombre: _nombreCtrl.text.trim(),
      significado: _significadoCtrl.text.trim(),
      descripcionExtendida: _descripcionCtrl.text.trim(),
      orden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
      imageUrl: finalImageUrl,
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
