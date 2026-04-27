import 'package:flutter/material.dart';

class RitualesScreen extends StatelessWidget {
  const RitualesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rituales = [
      {
        'nombre': 'Ritual de Sanación',
        'icono': Icons.healing_outlined,
        'descripcion': 'Sana cuerpo, mente y espíritu. Restaura tu energía vital',
        'elementos': ['Velas blancas', 'Incienso de sándalo', 'Cristales de cuarzo'],
      },
      {
        'nombre': 'Abre Caminos',
        'icono': Icons.alt_route_outlined,
        'descripcion': 'Elimina obstáculos y abre nuevas oportunidades en tu vida',
        'elementos': ['Velas amarillas', 'Miel', 'Canela'],
      },
      {
        'nombre': 'Ritual de Atracción',
        'icono': Icons.favorite_outline,
        'descripcion': 'Atrae amor, amistad y relaciones positivas',
        'elementos': ['Velas rosas', 'Pétalos de rosa', 'Aceite de rosas'],
      },
      {
        'nombre': 'Ritual de Dinero',
        'icono': Icons.attach_money_outlined,
        'descripcion': 'Atrae abundancia y prosperidad económica',
        'elementos': ['Velas verdes', 'Monedas', 'Hojas de laurel'],
      },
      {
        'nombre': 'Trabajo o Empleo',
        'icono': Icons.work_outline,
        'descripcion': 'Atrae oportunidades laborales y éxito profesional',
        'elementos': ['Velas naranjas', 'Sal', 'Romero'],
      },
      {
        'nombre': 'Alejar Malas Energías',
        'icono': Icons.shield_outlined,
        'descripcion': 'Protección contra energías negativas y malas vibras',
        'elementos': ['Velas negras', 'Sal gruesa', 'Ruda'],
      },
      {
        'nombre': 'Alejamiento de Malos Vecinos',
        'icono': Icons.people_outline,
        'descripcion': 'Aleja personas tóxicas y conflictivas de tu entorno',
        'elementos': ['Velas rojas', 'Vinagre', 'Pimienta negra'],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'RITUALES',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: rituales.length,
          itemBuilder: (context, index) {
            final ritual = rituales[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB71C1C),
                  width: 1,
                ),
                color: Colors.black.withOpacity(0.5),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFB71C1C),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    ritual['icono'],
                    color: const Color(0xFFB71C1C),
                    size: 24,
                  ),
                ),
                title: Text(
                  ritual['nombre'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ritual['descripcion'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
                iconColor: const Color(0xFFB71C1C),
                collapsedIconColor: const Color(0xFFB71C1C),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFB71C1C),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Elementos necesarios:',
                          style: TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          ritual['elementos'].length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Color(0xFFB71C1C),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ritual['elementos'][i],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _solicitarRitual(context, ritual);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'SOLICITAR RITUAL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _solicitarRitual(BuildContext context, Map<String, dynamic> ritual) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        title: Row(
          children: [
            Icon(
              ritual['icono'],
              color: const Color(0xFFB71C1C),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ritual['nombre'],
                style: const TextStyle(
                  color: Color(0xFFB71C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ritual['descripcion'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFB71C1C),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFB71C1C),
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Solicitud Enviada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nos pondremos en contacto contigo para coordinar el ritual',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
