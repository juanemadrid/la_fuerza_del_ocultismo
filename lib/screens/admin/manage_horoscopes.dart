import 'package:flutter/material.dart';
import '../../models/horoscope_model.dart';
import '../../services/database_service.dart';

class ManageHoroscopes extends StatefulWidget {
  const ManageHoroscopes({super.key});

  @override
  State<ManageHoroscopes> createState() => _ManageHoroscopesState();
}

class _ManageHoroscopesState extends State<ManageHoroscopes> {
  final DatabaseService _db = DatabaseService();
  final _predictionController = TextEditingController();
  String? _selectedSign;

  final List<String> _signs = [
    'Aries', 'Tauro', 'Géminis', 'Cáncer', 'Leo', 'Virgo',
    'Libra', 'Escorpio', 'Sagitario', 'Capricornio', 'Acuario', 'Piscis'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GESTIONAR HORÓSCOPOS')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSign,
              dropdownColor: const Color(0xFF1A1A1A),
              decoration: const InputDecoration(
                labelText: 'Seleccionar Signo',
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              items: _signs.map((sign) {
                return DropdownMenuItem(value: sign, child: Text(sign));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedSign = val);
                if (val != null) _loadPrediction(val);
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _predictionController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Predicción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePrediction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('GUARDAR PREDICCIÓN'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadPrediction(String sign) async {
    final horoscope = await _db.getHoroscope(sign);
    if (horoscope != null) {
      _predictionController.text = horoscope.prediction;
    } else {
      _predictionController.clear();
    }
  }

  void _savePrediction() async {
    if (_selectedSign == null || _predictionController.text.isEmpty) return;

    final horoscope = HoroscopeModel(
      sign: _selectedSign!,
      prediction: _predictionController.text,
      lastUpdated: DateTime.now(),
    );

    await _db.updateHoroscope(horoscope);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Horóscopo actualizado con éxito')),
    );
  }
}
