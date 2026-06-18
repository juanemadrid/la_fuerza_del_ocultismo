import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../login_screen.dart';
import 'admin_stats.dart';
import 'manage_config.dart';
import 'manage_horoscopes.dart';
import 'manage_limpiezas.dart';
import 'manage_pdfs.dart';
import 'manage_planes.dart';
import 'manage_rituales.dart';
import 'manage_tarot.dart';
import 'manage_users.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      bottomNavigationBar: _AdminBottomNav(
        selectedIndex: _selectedIndex,
        onChanged: (index) {
          if (index == 1) {
            _open(context, const ManagePlanes());
          } else if (index == 2) {
            _open(context, const ManageUsers());
          } else if (index == 3) {
            _open(context, const ManageConfig());
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
      body: SafeArea(
        child: StreamBuilder<List<UserModel>>(
          stream: DatabaseService().streamUsers(),
          builder: (context, snapshot) {
            final allUsers = snapshot.data ?? [];
            final clientes = allUsers.where((u) => u.role != 'admin').toList();
            final activos = clientes.where((u) => u.isMembershipActive).length;
            final pendientes = clientes
                .where((u) => u.pendingApproval && u.subscriptionExpiry == null)
                .length;
            final vencidos = clientes
                .where((u) => !u.isMembershipActive && u.subscriptionExpiry != null)
                .length;
            final ingresoEstimado = clientes.fold<double>(
              0,
              (total, u) => total + (u.pendingPlanPrecio ?? 0),
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, user, pendientes)),
                SliverToBoxAdapter(
                  child: _HeroSummary(
                    total: clientes.length,
                    activos: activos,
                    pendientes: pendientes,
                    vencidos: vencidos,
                    ingreso: ingresoEstimado,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionTitle(
                    title: 'Accesos rápidos',
                    action: 'Gestionar',
                    onTap: () => _open(context, const AdminStats()),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.22,
                    children: [
                      _QuickActionCard(
                        icon: Icons.card_membership_rounded,
                        title: 'Planes',
                        subtitle: 'Precios y beneficios',
                        value: 'Suscripciones',
                        color: Colors.amber,
                        onTap: () => _open(context, const ManagePlanes()),
                      ),
                      _QuickActionCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Usuarios',
                        subtitle: '$activos activos',
                        value: '${clientes.length}',
                        color: const Color(0xFFE53935),
                        onTap: () => _open(context, const ManageUsers()),
                      ),
                      _QuickActionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Contenido',
                        subtitle: 'Rituales, tarot y guías',
                        value: '4 áreas',
                        color: Color(0xFFEF233C),
                        onTap: () => _showContentSheet(context),
                      ),
                      _QuickActionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Pagos',
                        subtitle: 'Pendientes y estados',
                        value: '$pendientes',
                        color: Colors.greenAccent,
                        onTap: () => _open(context, const ManageUsers()),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 22)),
                SliverToBoxAdapter(
                  child: _SectionTitle(
                    title: 'Gestión principal',
                    action: 'Ver métricas',
                    onTap: () => _open(context, const AdminStats()),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ManagementTile(
                        icon: Icons.analytics_rounded,
                        title: 'Dashboard y estadísticas',
                        subtitle: 'Resumen, membresías activas y vencimientos',
                        badge: '${clientes.length} usuarios',
                        color: Colors.redAccent,
                        onTap: () => _open(context, const AdminStats()),
                      ),
                      _ManagementTile(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Gestión de planes',
                        subtitle: 'Crear, editar, activar o eliminar planes',
                        badge: 'Planes',
                        color: Colors.amber,
                        onTap: () => _open(context, const ManagePlanes()),
                      ),
                      _ManagementTile(
                        icon: Icons.collections_bookmark_rounded,
                        title: 'Gestión de contenido',
                        subtitle: 'Cursos, rituales, artículos y guías PDF',
                        badge: 'Contenido',
                        color: Color(0xFFC0121C),
                        onTap: () => _showContentSheet(context),
                      ),
                      _ManagementTile(
                        icon: Icons.notifications_active_rounded,
                        title: 'Notificaciones',
                        subtitle: 'Preparado para envíos a usuarios',
                        badge: 'Vista previa',
                        color: Color(0xFFB71C1C),
                        onTap: () => _showComingSoon(context, 'Notificaciones'),
                      ),
                      _ManagementTile(
                        icon: Icons.settings_rounded,
                        title: 'Configuración general',
                        subtitle: 'WhatsApp, anuncios y ajustes de la app',
                        badge: 'Ajustes',
                        color: Color(0xFF8D0000),
                        onTap: () => _open(context, const ManageConfig()),
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user, int pendientes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAS FUERZAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                Text(
                  user?.name.isNotEmpty == true
                      ? 'Panel admin · ${user!.name}'
                      : 'Panel admin · Suscripciones',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Pendientes',
                onPressed: () => _open(context, const ManageUsers()),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
              ),
              if (pendientes > 0)
                Positioned(
                  right: 10,
                  top: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmarCerrarSesion(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showContentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gestión de contenido',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _SheetAction(icon: Icons.star_rounded, title: 'Horóscopo', onTap: () => _replaceSheet(context, const ManageHoroscopes())),
              _SheetAction(icon: Icons.auto_awesome_rounded, title: 'Tarot', onTap: () => _replaceSheet(context, const ManageTarot())),
              _SheetAction(icon: Icons.water_drop_rounded, title: 'Limpiezas', onTap: () => _replaceSheet(context, const ManageLimpiezas())),
              _SheetAction(icon: Icons.auto_fix_high_rounded, title: 'Rituales', onTap: () => _replaceSheet(context, const ManageRituales())),
              _SheetAction(icon: Icons.picture_as_pdf_rounded, title: 'Contenido PDF', onTap: () => _replaceSheet(context, const ManagePDFs())),
            ],
          ),
        ),
      ),
    );
  }

  void _replaceSheet(BuildContext context, Widget screen) {
    Navigator.pop(context);
    _open(context, screen);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: const Color(0xFFB71C1C),
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFB71C1C)),
        ),
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Serás redirigido a la pantalla de inicio.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
            child: const Text('CERRAR SESIÓN'),
          ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final int total;
  final int activos;
  final int pendientes;
  final int vencidos;
  final double ingreso;

  const _HeroSummary({
    required this.total,
    required this.activos,
    required this.pendientes,
    required this.vencidos,
    required this.ingreso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B0707), Color(0xFF090909), Color(0xFF130000)],
        ),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Total Suscriptores', value: '$total', accent: '+12%', color: Colors.greenAccent)),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(label: 'Ingresos Totales', value: '\$${ingreso.toStringAsFixed(0)}', accent: 'Pendiente', color: Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Suscripciones Activas', value: '$activos', accent: '$vencidos vencidas', color: Colors.lightGreenAccent)),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(label: 'Nuevos Registros', value: '$pendientes', accent: 'Por aprobar', color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 118,
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withOpacity(0.34),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: CustomPaint(painter: _RevenueChartPainter()),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String accent;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.accent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(accent, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionTitle({required this.title, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: Color(0xFFE53935)))),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF101010),
            border: Border.all(color: color.withOpacity(0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 21),
                  ),
                  Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF101010),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: color.withOpacity(0.22)),
                  ),
                  child: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SheetAction({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFE53935)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _AdminBottomNav({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090909),
        border: Border(top: BorderSide(color: Color(0xFF171717))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', selected: selectedIndex == 0, onTap: () => onChanged(0)),
              _NavItem(icon: Icons.workspace_premium_rounded, label: 'Planes', selected: selectedIndex == 1, onTap: () => onChanged(1)),
              _NavItem(icon: Icons.people_rounded, label: 'Usuarios', selected: selectedIndex == 2, onTap: () => onChanged(2)),
              _NavItem(icon: Icons.settings_rounded, label: 'Config', selected: selectedIndex == 3, onTap: () => onChanged(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFE53935) : Colors.white38;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[
      Offset(0, size.height * .78),
      Offset(size.width * .13, size.height * .62),
      Offset(size.width * .26, size.height * .70),
      Offset(size.width * .39, size.height * .44),
      Offset(size.width * .52, size.height * .55),
      Offset(size.width * .65, size.height * .31),
      Offset(size.width * .78, size.height * .40),
      Offset(size.width, size.height * .13),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFE53935).withOpacity(0.26), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
