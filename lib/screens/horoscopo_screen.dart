import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/responsive_container.dart';

class HoroscopoScreen extends StatefulWidget {
  const HoroscopoScreen({super.key});

  @override
  State<HoroscopoScreen> createState() => _HoroscopoScreenState();
}

class _HoroscopoScreenState extends State<HoroscopoScreen> {
  String? _signoSeleccionado;
  String _prediccion = '';

  final List<Map<String, dynamic>> _signos = [
    {'nombre': 'Aries', 'icono': '♈', 'fechas': 'Mar 21 - Abr 19'},
    {'nombre': 'Tauro', 'icono': '♉', 'fechas': 'Abr 20 - May 20'},
    {'nombre': 'Géminis', 'icono': '♊', 'fechas': 'May 21 - Jun 20'},
    {'nombre': 'Cáncer', 'icono': '♋', 'fechas': 'Jun 21 - Jul 22'},
    {'nombre': 'Leo', 'icono': '♌', 'fechas': 'Jul 23 - Ago 22'},
    {'nombre': 'Virgo', 'icono': '♍', 'fechas': 'Ago 23 - Sep 22'},
    {'nombre': 'Libra', 'icono': '♎', 'fechas': 'Sep 23 - Oct 22'},
    {'nombre': 'Escorpio', 'icono': '♏', 'fechas': 'Oct 23 - Nov 21'},
    {'nombre': 'Sagitario', 'icono': '♐', 'fechas': 'Nov 22 - Dic 21'},
    {'nombre': 'Capricornio', 'icono': '♑', 'fechas': 'Dic 22 - Ene 19'},
    {'nombre': 'Acuario', 'icono': '♒', 'fechas': 'Ene 20 - Feb 18'},
    {'nombre': 'Piscis', 'icono': '♓', 'fechas': 'Feb 19 - Mar 20'},
  ];

  final Map<String, List<String>> _predicciones = {
    'Aries': [
      'Hoy es un día propicio para tomar decisiones importantes. Tu energía está en su punto máximo.',
      'Las estrellas te favorecen en el amor. Abre tu corazón a nuevas posibilidades.',
      'Tu intuición te guiará hacia oportunidades financieras inesperadas.',
    ],
    'Tauro': [
      'La paciencia será tu mejor aliada hoy. No te apresures en tomar decisiones.',
      'Un encuentro fortuito podría cambiar tu perspectiva sobre una situación importante.',
      'Es momento de invertir en ti mismo. Tu bienestar es prioritario.',
    ],
    'Géminis': [
      'Tu creatividad está en su punto más alto. Aprovecha para iniciar nuevos proyectos.',
      'La comunicación será clave hoy. Expresa tus sentimientos con claridad.',
      'Las oportunidades laborales tocan a tu puerta. Mantén los ojos abiertos.',
    ],
    'Cáncer': [
      'Tu sensibilidad te permitirá conectar profundamente con quienes te rodean.',
      'Es un buen momento para fortalecer lazos familiares y resolver conflictos.',
      'Confía en tu intuición, te está guiando por el camino correcto.',
    ],
    'Leo': [
      'Tu carisma natural atraerá nuevas oportunidades. Brilla con luz propia.',
      'El reconocimiento que buscas está cerca. Sigue trabajando con pasión.',
      'En el amor, la sinceridad será tu mejor carta de presentación.',
    ],
    'Virgo': [
      'Tu atención al detalle te ayudará a resolver un problema complejo.',
      'Es momento de organizarte y establecer prioridades claras.',
      'La salud requiere tu atención. Escucha las señales de tu cuerpo.',
    ],
    'Libra': [
      'El equilibrio que buscas está más cerca de lo que piensas.',
      'Las relaciones personales florecen bajo tu cuidado y atención.',
      'Una decisión importante requerirá que confíes en tu juicio.',
    ],
    'Escorpio': [
      'Tu intensidad emocional te llevará a descubrimientos profundos sobre ti mismo.',
      'La transformación que buscas comienza desde dentro. Abraza el cambio.',
      'Tu magnetismo personal está en su punto más alto. Úsalo sabiamente.',
    ],
    'Sagitario': [
      'La aventura te llama. Es momento de explorar nuevos horizontes.',
      'Tu optimismo contagioso inspirará a quienes te rodean.',
      'Las oportunidades de crecimiento están en todas partes. Mantén la mente abierta.',
    ],
    'Capricornio': [
      'Tu disciplina y perseverancia están dando frutos. Sigue adelante.',
      'Es momento de celebrar tus logros y reconocer tu progreso.',
      'Las metas a largo plazo requieren tu atención. Planifica con cuidado.',
    ],
    'Acuario': [
      'Tu originalidad te distingue. No temas ser diferente.',
      'Las conexiones sociales te abrirán puertas inesperadas.',
      'Tu visión del futuro es clara. Confía en tus ideas innovadoras.',
    ],
    'Piscis': [
      'Tu empatía y compasión son tus mayores fortalezas hoy.',
      'Los sueños te revelarán mensajes importantes. Presta atención.',
      'Es momento de dejar ir lo que ya no te sirve. Libérate.',
    ],
  };

  void _generarPrediccion() {
    if (_signoSeleccionado != null) {
      final random = Random();
      final predicciones = _predicciones[_signoSeleccionado]!;
      setState(() {
        _prediccion = predicciones[random.nextInt(predicciones.length)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'HORÓSCOPO',
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
        child: ResponsiveContainer(
          maxWidth: 800, // Wider for the grid
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Selecciona tu signo zodiacal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Grid de signos - Responsive
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _signos.length,
                  itemBuilder: (context, index) {
                    final signo = _signos[index];
                    final isSelected = _signoSeleccionado == signo['nombre'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _signoSeleccionado = signo['nombre'];
                          _prediccion = '';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFB71C1C) : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                          color: isSelected 
                              ? const Color(0xFFB71C1C).withOpacity(0.2)
                              : Colors.black.withOpacity(0.3),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFFB71C1C).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              signo['icono'],
                              style: TextStyle(
                                fontSize: 40,
                                color: isSelected ? const Color(0xFFB71C1C) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              signo['nombre'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              signo['fechas'],
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Botón consultar
                if (_signoSeleccionado != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _generarPrediccion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CONSULTAR HORÓSCOPO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                
                // Predicción
                if (_prediccion.isNotEmpty) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
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
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFB71C1C),
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tu horóscopo para $_signoSeleccionado',
                          style: const TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _prediccion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
