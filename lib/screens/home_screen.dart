import 'package:flutter/material.dart';
import 'perfil_screen.dart';
import 'horoscopo_screen.dart';
import 'tarot_screen.dart';
import 'limpiezas_screen.dart';
import 'rituales_screen.dart';
import '../widgets/responsive_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
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
        child: SafeArea(
          child: Column(
            children: [
              // Header con menú hamburguesa
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Color(0xFFB71C1C),
                        size: 32,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
              ),
              
              // Contenido principal - MENÚ
              Expanded(
                child: ResponsiveContainer(
                  maxWidth: 600, // Medium width for the menu
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título MENÚ
                        const Center(
                          child: Text(
                            'MENÚ',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB71C1C),
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFB71C1C),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // PERFIL
                        _buildMenuSection(
                          icon: Icons.person_outline,
                          title: 'PERFIL',
                          items: [],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PerfilScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // HORÓSCOPO
                        _buildMenuSection(
                          icon: Icons.star_outline,
                          title: 'HORÓSCOPO',
                          items: ['Horóscopo'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HoroscopoScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // TAROT
                        _buildMenuSection(
                          icon: Icons.auto_awesome_outlined,
                          title: 'TAROT',
                          items: [
                            'pasado',
                            'presente',
                            'posible futuro',
                            'pregunta directa',
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TarotScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // LIMPIEZAS
                        _buildMenuSection(
                          icon: Icons.water_drop_outlined,
                          title: 'LIMPIEZAS',
                          items: [
                            'cuerpo',
                            'alma',
                            'espíritu',
                            'negocios',
                            'Casa',
                            'lotes',
                            'propiedad',
                            'vehículos',
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LimpiezasScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // RITUALES
                        _buildMenuSection(
                          icon: Icons.auto_fix_high_outlined,
                          title: 'RITUALES',
                          items: [
                            'sanación',
                            'abre caminos',
                            'atracción',
                            'dinero',
                            'trabajo o empleo',
                            'alejarme de malas energías',
                            'alejamiento de malos vecinos',
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RitualesScreen()),
                            );
                          },
                        ),
                      ],
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

  Widget _buildMenuSection({
    required IconData icon,
    required String title,
    required List<String> items,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB71C1C),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFB71C1C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFB71C1C),
                  size: 16,
                ),
            ],
          ),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // Línea decorativa
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFB71C1C),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          // Header del drawer con logo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFB71C1C),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo pequeño
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFB71C1C),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.change_history,
                    color: Color(0xFFB71C1C),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'La Fuerza',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'Del Ocultismo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'PERFIL',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PerfilScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'MENÚ',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.star_outline,
                  title: 'HORÓSCOPO',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HoroscopoScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.auto_awesome_outlined,
                  title: 'TAROT',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TarotScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Cerrar sesión
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFB71C1C),
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFB71C1C),
              ),
              title: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      color: isSelected ? const Color(0xFF4A0000) : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFFB71C1C),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
