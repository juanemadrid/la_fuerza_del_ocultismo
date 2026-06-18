import 'package:flutter/material.dart';
import '../../models/horoscope_model.dart';
import '../../services/database_service.dart';

class ManageHoroscopes extends StatelessWidget {
  const ManageHoroscopes({super.key});

  static const List<Map<String, String>> _signs = [
    {'name': 'Aries', 'symbol': '♈'},
    {'name': 'Tauro', 'symbol': '♉'},
    {'name': 'Géminis', 'symbol': '♊'},
    {'name': 'Cáncer', 'symbol': '♋'},
    {'name': 'Leo', 'symbol': '♌'},
    {'name': 'Virgo', 'symbol': '♍'},
    {'name': 'Libra', 'symbol': '♎'},
    {'name': 'Escorpio', 'symbol': '♏'},
    {'name': 'Sagitario', 'symbol': '♐'},
    {'name': 'Capricornio', 'symbol': '♑'},
    {'name': 'Acuario', 'symbol': '♒'},
    {'name': 'Piscis', 'symbol': '♓'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR HORÓSCOPOS',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: StreamBuilder<List<HoroscopeModel>>(
          stream: DatabaseService().streamHoroscopes(),
          builder: (context, snapshot) {
            final horoscopes = snapshot.data ?? [];
            final Map<String, HoroscopeModel> horoscopeMap = {
              for (final h in horoscopes) h.sign: h,
            };

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _signs.length,
              itemBuilder: (context, index) {
                final sign = _signs[index];
                final name = sign['name']!;
                final symbol = sign['symbol']!;
                final horoscope = horoscopeMap[name];
                final hasContent =
                    horoscope != null && horoscope.prediction.isNotEmpty;

                return _SignCard(
                  name: name,
                  symbol: symbol,
                  horoscope: horoscope,
                  hasContent: hasContent,
                  onTap: () => _openEditor(context, name, symbol, horoscope),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, String name, String symbol,
      HoroscopeModel? horoscope) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HoroscopeEditor(
          signName: name,
          signSymbol: symbol,
          horoscope: horoscope,
        ),
      ),
    );
  }
}

// ─── Sign Card ────────────────────────────────────────────────────────────────

class _SignCard extends StatelessWidget {
  final String name;
  final String symbol;
  final HoroscopeModel? horoscope;
  final bool hasContent;
  final VoidCallback onTap;

  const _SignCard({
    required this.name,
    required this.symbol,
    required this.horoscope,
    required this.hasContent,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasContent
                ? const Color(0xFFB71C1C).withOpacity(0.6)
                : Colors.white12,
            width: 1.5,
          ),
          color: hasContent
              ? const Color(0xFFB71C1C).withOpacity(0.06)
              : Colors.white.withOpacity(0.03),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 28,
                    color: hasContent
                        ? const Color(0xFFB71C1C)
                        : Colors.white38,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: hasContent
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    border: Border.all(
                      color: hasContent
                          ? Colors.green.withOpacity(0.5)
                          : Colors.orange.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    hasContent ? 'OK' : 'VACÍO',
                    style: TextStyle(
                      color: hasContent ? Colors.green : Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            if (horoscope != null) ...[
              Text(
                'Act: ${_formatDate(horoscope!.lastUpdated)}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  horoscope!.prediction,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              const Text(
                'Sin predicción',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const Spacer(),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: const Color(0xFFB71C1C).withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'EDITAR',
                  style: TextStyle(
                    color: const Color(0xFFB71C1C).withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Horoscope Editor ─────────────────────────────────────────────────────────

class _HoroscopeEditor extends StatefulWidget {
  final String signName;
  final String signSymbol;
  final HoroscopeModel? horoscope;

  const _HoroscopeEditor({
    required this.signName,
    required this.signSymbol,
    this.horoscope,
  });

  @override
  State<_HoroscopeEditor> createState() => _HoroscopeEditorState();
}

class _HoroscopeEditorState extends State<_HoroscopeEditor> {
  late TextEditingController _predictionController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _predictionController =
        TextEditingController(text: widget.horoscope?.prediction ?? '');
  }

  @override
  void dispose() {
    _predictionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.signSymbol,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.signName.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(
                      color: const Color(0xFFB71C1C).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.signSymbol,
                      style: const TextStyle(
                          fontSize: 36, color: Color(0xFFB71C1C)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.signName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (widget.horoscope != null)
                            Text(
                              'Última actualización: ${_formatDate(widget.horoscope!.lastUpdated)}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            )
                          else
                            const Text(
                              'Sin predicción configurada',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'PREDICCIÓN',
                style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),

              // Text editor
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _predictionController,
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _predictionController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.6,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Escribe la predicción para ${widget.signName}...',
                              hintStyle: const TextStyle(
                                  color: Colors.white24, fontSize: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.white12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFB71C1C)),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${value.text.length} caracteres',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'GUARDANDO...' : 'GUARDAR PREDICCIÓN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _predictionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La predicción no puede estar vacía'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final horoscope = HoroscopeModel(
        sign: widget.signName,
        prediction: text,
        lastUpdated: DateTime.now(),
      );
      await DatabaseService().updateHoroscope(horoscope);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Predicción de ${widget.signName} guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
