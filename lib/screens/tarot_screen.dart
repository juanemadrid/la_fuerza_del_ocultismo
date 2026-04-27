import 'package:flutter/material.dart';
import 'dart:math';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  String? _tipoLectura;
  List<Map<String, String>> _cartasSeleccionadas = [];
  final TextEditingController _preguntaController = TextEditingController();

  final List<Map<String, String>> _cartas = [
    {'nombre': 'El Loco', 'significado': 'Nuevos comienzos, espontaneidad, fe en el futuro'},
    {'nombre': 'El Mago', 'significado': 'Manifestación, recursos, poder, acción inspirada'},
    {'nombre': 'La Sacerdotisa', 'significado': 'Intuición, misterio, subconsciente'},
    {'nombre': 'La Emperatriz', 'significado': 'Feminidad, belleza, naturaleza, abundancia'},
    {'nombre': 'El Emperador', 'significado': 'Autoridad, estructura, control, padre'},
    {'nombre': 'El Hierofante', 'significado': 'Tradición, conformidad, moralidad, ética'},
    {'nombre': 'Los Enamorados', 'significado': 'Amor, armonía, relaciones, valores'},
    {'nombre': 'El Carro', 'significado': 'Control, voluntad, victoria, determinación'},
    {'nombre': 'La Fuerza', 'significado': 'Fuerza interior, coraje, paciencia, compasión'},
    {'nombre': 'El Ermitaño', 'significado': 'Búsqueda interior, introspección, guía'},
    {'nombre': 'La Rueda de la Fortuna', 'significado': 'Cambio, ciclos, destino, punto de inflexión'},
    {'nombre': 'La Justicia', 'significado': 'Justicia, equidad, verdad, ley'},
    {'nombre': 'El Colgado', 'significado': 'Pausa, rendición, dejar ir, nueva perspectiva'},
    {'nombre': 'La Muerte', 'significado': 'Finales, transformación, transición, liberación'},
    {'nombre': 'La Templanza', 'significado': 'Balance, moderación, paciencia, propósito'},
    {'nombre': 'El Diablo', 'significado': 'Ataduras, adicción, materialismo, ignorancia'},
    {'nombre': 'La Torre', 'significado': 'Cambio repentino, revelación, despertar'},
    {'nombre': 'La Estrella', 'significado': 'Esperanza, fe, renovación, espiritualidad'},
    {'nombre': 'La Luna', 'significado': 'Ilusión, miedo, ansiedad, subconsciente'},
    {'nombre': 'El Sol', 'significado': 'Alegría, éxito, celebración, positividad'},
    {'nombre': 'El Juicio', 'significado': 'Juicio, renacimiento, perdón, llamado interior'},
    {'nombre': 'El Mundo', 'significado': 'Completitud, logro, viaje, cumplimiento'},
  ];

  void _realizarLectura() {
    if (_tipoLectura == null) return;
    
    if (_tipoLectura == 'pregunta directa' && _preguntaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe tu pregunta'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    final random = Random();
    final cartasBarajadas = List<Map<String, String>>.from(_cartas)..shuffle(random);
    
    int numCartas = 1;
    if (_tipoLectura == 'pasado') numCartas = 1;
    else if (_tipoLectura == 'presente') numCartas = 1;
    else if (_tipoLectura == 'posible futuro') numCartas = 3;
    else if (_tipoLectura == 'pregunta directa') numCartas = 1;

    setState(() {
      _cartasSeleccionadas = cartasBarajadas.take(numCartas).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'TAROT',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFF1A0000),
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el tipo de lectura',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opciones de lectura
              _buildTipoLectura('pasado', 'Pasado', 'Descubre eventos que te han marcado'),
              _buildTipoLectura('presente', 'Presente', 'Comprende tu situación actual'),
              _buildTipoLectura('posible futuro', 'Posible Futuro', 'Vislumbra lo que puede venir'),
              _buildTipoLectura('pregunta directa', 'Pregunta Directa', 'Obtén respuesta a tu pregunta'),
              
              // Campo de pregunta
              if (_tipoLectura == 'pregunta directa') ...[
                const SizedBox(height: 20),
                const Text(
                  'Escribe tu pregunta',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFB71C1C),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _preguntaController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta aquí...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Botón consultar
              if (_tipoLectura != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _realizarLectura,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONSULTAR CARTAS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              
              // Resultado
              if (_cartasSeleccionadas.isNotEmpty) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Tu lectura',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                ..._cartasSeleccionadas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final carta = entry.value;
                  String posicion = '';
                  if (_tipoLectura == 'posible futuro') {
                    if (index == 0) posicion = 'Pasado';
                    else if (index == 1) posicion = 'Presente';
                    else posicion = 'Futuro';
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFB71C1C),
                          width: 2,
                        ),
                        color: Colors.black.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C1C).withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (posicion.isNotEmpty)
                            Text(
                              posicion,
                              style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFB71C1C),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            carta['nombre']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            carta['significado']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoLectura(String valor, String titulo, String descripcion) {
    final isSelected = _tipoLectura == valor;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoLectura = valor;
          _cartasSeleccionadas = [];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFB71C1C) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? const Color(0xFFB71C1C).withOpacity(0.2)
              : Colors.black.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFB71C1C) : Colors.white38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    super.dispose();
  }
}
