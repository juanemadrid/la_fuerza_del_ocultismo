import 'package:flutter/material.dart';

class LimpiezasScreen extends StatelessWidget {
  const LimpiezasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> limpiezas = [
      {
        'nombre': 'Limpieza de Cuerpo',
        'icono': Icons.person_outline,
        'descripcion': 'Purifica tu energía física y elimina bloqueos corporales',
        'duracion': '30 min',
      },
      {
        'nombre': 'Limpieza de Alma',
        'icono': Icons.favorite_outline,
        'descripcion': 'Sana heridas emocionales y libera cargas del pasado',
        'duracion': '45 min',
      },
      {
        'nombre': 'Limpieza de Espíritu',
        'icono': Icons.auto_awesome,
        'descripcion': 'Conecta con tu esencia divina y eleva tu vibración',
        'duracion': '60 min',
      },
      {
        'nombre': 'Limpieza de Negocios',
        'icono': Icons.business_outlined,
        'descripcion': 'Atrae prosperidad y elimina energías negativas del trabajo',
        'duracion': '45 min',
      },
      {
        'nombre': 'Limpieza de Casa',
        'icono': Icons.home_outlined,
        'descripcion': 'Purifica tu hogar y crea un espacio de paz y armonía',
        'duracion': '60 min',
      },
      {
        'nombre': 'Limpieza de Lotes',
        'icono': Icons.landscape_outlined,
        'descripcion': 'Limpia terrenos y prepara espacios para nuevos proyectos',
        'duracion': '90 min',
      },
      {
        'nombre': 'Limpieza de Propiedad',
        'icono': Icons.apartment_outlined,
        'descripcion': 'Purifica propiedades completas y elimina energías estancadas',
        'duracion': '120 min',
      },
      {
        'nombre': 'Limpieza de Vehículos',
        'icono': Icons.directions_car_outlined,
        'descripcion': 'Protege tus viajes y elimina energías negativas del camino',
        'duracion': '30 min',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'LIMPIEZAS',
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
          itemCount: limpiezas.length,
          itemBuilder: (context, index) {
            final limpieza = limpiezas[index];
            
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
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
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
                    limpieza['icono'],
                    color: const Color(0xFFB71C1C),
                    size: 24,
                  ),
                ),
                title: Text(
                  limpieza['nombre'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      limpieza['descripcion'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFFB71C1C),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          limpieza['duracion'],
                          style: const TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _mostrarDetalles(context, limpieza);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Solicitar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarDetalles(BuildContext context, Map<String, dynamic> limpieza) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        title: Text(
          limpieza['nombre'],
          style: const TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              limpieza['descripcion'],
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Duración: ${limpieza['duracion']}',
              style: const TextStyle(color: Color(0xFFB71C1C)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu solicitud ha sido enviada. Nos pondremos en contacto contigo pronto.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFB71C1C)),
            ),
          ),
        ],
      ),
    );
  }
}
