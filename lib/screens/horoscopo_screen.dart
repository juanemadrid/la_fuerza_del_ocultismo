import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/responsive_container.dart';

class HoroscopoScreen extends StatefulWidget {
  const HoroscopoScreen({super.key});

  @override
  State<HoroscopoScreen> createState() => _HoroscopoScreenState();
}

class _HoroscopoScreenState extends State<HoroscopoScreen> {
  String? _signoSeleccionado;
  String _prediccion = '';
  bool _isLoading = false;
  bool _isSignLocked = false;

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

  @override
  void initState() {
    super.initState();
    _checkUserSign();
  }

  void _checkUserSign() {
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user != null && user.zodiacSign.isNotEmpty) {
      setState(() {
        _signoSeleccionado = user.zodiacSign;
        _isSignLocked = user.isSubscribed;
      });
      _cargarPrediccion(user.zodiacSign);
    }
  }

  Future<void> _cargarPrediccion(String sign) async {
    setState(() => _isLoading = true);
    final horoscope = await DatabaseService().getHoroscope(sign);
    if (mounted) {
      setState(() {
        _prediccion = horoscope?.prediction ??
            'No hay predicción disponible para hoy. Consulta con el maestro.';
        _isLoading = false;
      });
    }
  }

  void _generarPrediccion() {
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user == null || !user.isSubscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Necesitas una suscripción activa para consultar el horóscopo'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    if (_signoSeleccionado != null) {
      _cargarPrediccion(_signoSeleccionado!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;

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
                if (user != null && !user.isSubscribed)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Activa tu suscripción para desbloquear el horóscopo personalizado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                        if (_isSignLocked) return;
                        setState(() {
                          _signoSeleccionado = signo['nombre'];
                          _prediccion = '';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFB71C1C)
                                : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                          color: isSelected
                              ? const Color(0xFFB71C1C).withOpacity(0.2)
                              : Colors.black.withOpacity(0.3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFB71C1C)
                                        .withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              signo['icono'],
                              style: TextStyle(
                                fontSize: 40,
                                color: isSelected
                                    ? const Color(0xFFB71C1C)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              signo['nombre'],
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                      onPressed:
                          _isLoading || (user != null && !user.isSubscribed)
                              ? null
                              : _generarPrediccion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
