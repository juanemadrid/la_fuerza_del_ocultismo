import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'admin/admin_dashboard.dart';
import 'horoscopo_screen.dart';
import 'limpiezas_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'rituales_screen.dart';
import 'maestro_screen.dart';
import 'tarot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _launchWhatsApp({String? message}) async {
    try {
      final link = await DatabaseService().getWhatsAppLink();
      if (link.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El enlace de WhatsApp no está configurado por el administrador.'),
            ),
          );
        }
        return;
      }
      final suffix =
          message == null ? '' : '?text=${Uri.encodeComponent(message)}';
      final url = Uri.parse('$link$suffix');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp. Verifica si la aplicación está instalada.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgBase,
      drawer: _buildDrawer(context, user),
      floatingActionButton: _buildFAB(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundRadial),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, user)),
              SliverToBoxAdapter(child: _buildHero(context, user)),
              SliverToBoxAdapter(child: _CartaDelDia()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Servicios Espirituales',
                  'Servicios del portal espiritual',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                  children: [
                    _ServiceCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Tarot',
                      subtitle: 'Pasado, presente, futuro y pregunta directa',
                      gradient: AppGradients.tarotCard,
                      accentColor: AppColors.primaryLight,
                      badgeText: user?.isMembershipActive == true ? 'PREMIUM' : 'GRATIS',
                      badgeTextColor: user?.isMembershipActive == true ? const Color(0xFF6EE7B7) : AppColors.gold,
                      badgeColor: user?.isMembershipActive == true ? const Color(0xFF064E3B).withOpacity(0.3) : AppColors.gold.withOpacity(0.12),
                      badgeBorderColor: user?.isMembershipActive == true ? const Color(0xFF6EE7B7).withOpacity(0.4) : AppColors.gold.withOpacity(0.4),
                      onTap: () => _open(context, const TarotScreen()),
                    ),
                    _ServiceCard(
                      icon: Icons.star_rounded,
                      title: 'Horóscopo',
                      subtitle: 'Guía por signo y energía del día',
                      gradient: AppGradients.horoscopoCard,
                      accentColor: AppColors.primaryLight,
                      badgeText: user?.isMembershipActive == true ? 'PREMIUM' : '1 GRATIS/MES',
                      badgeTextColor: user?.isMembershipActive == true ? const Color(0xFF6EE7B7) : AppColors.gold,
                      badgeColor: user?.isMembershipActive == true ? const Color(0xFF064E3B).withOpacity(0.3) : AppColors.gold.withOpacity(0.12),
                      badgeBorderColor: user?.isMembershipActive == true ? const Color(0xFF6EE7B7).withOpacity(0.4) : AppColors.gold.withOpacity(0.4),
                      onTap: () => _open(context, const HoroscopoScreen()),
                    ),
                    _ServiceCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Limpiezas',
                      subtitle: 'Cuerpo, hogar, negocio y protección',
                      gradient: AppGradients.limpiezasCard,
                      accentColor: AppColors.teal,
                      onTap: () => _open(context, const LimpiezasScreen()),
                    ),
                    _ServiceCard(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Rituales',
                      subtitle: 'Amor, dinero, caminos y defensa espiritual',
                      gradient: AppGradients.ritualesCard,
                      accentColor: const Color(0xFFF87171),
                      onTap: () => _open(context, const RitualesScreen()),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _PremiumActionPanel(
                  onTarot: () => _open(context, const TarotScreen()),
                  onContact: () => _launchWhatsApp(
                    message:
                        'Hola, quiero una orientación personalizada sobre tarot, limpieza o ritual.',
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FAB ────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _launchWhatsApp(
          message: 'Hola, quiero consultar un servicio espiritual desde la app.',
        ),
        backgroundColor: const Color(0xFF128C7E),
        elevation: 0,
        icon: const Icon(Icons.chat_rounded, color: Colors.white),
        label: Text(
          'Maestro',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.primaryLight, size: 28),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.gold, AppColors.primaryLight],
                  ).createShader(bounds),
                  child: Text(
                    'LAS FUERZAS',
                    style: GoogleFonts.cinzel(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.5,
                    ),
                  ),
                ),
                Text(
                  user?.zodiacSign.isNotEmpty == true
                      ? 'Portal místico · ${user!.zodiacSign}'
                      : 'Portal del ocultismo',
                  style: GoogleFonts.inter(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (user?.role == 'admin')
            IconButton(
              icon:
                  const Icon(Icons.admin_panel_settings_rounded, color: AppColors.gold),
              onPressed: () => _open(context, const AdminDashboard()),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded,
                color: AppColors.primaryLight),
            onPressed: () => _open(context, const PerfilScreen()),
          ),
        ],
      ),
    );
  }

  // ─── HERO ───────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context, UserModel? user) {
    final active = user?.isMembershipActive == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppGradients.heroCard,
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar con glow
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF3D0000), Color(0xFF1A0000)],
                  ),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.gold, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.isNotEmpty == true
                          ? 'Bienvenido, ${user!.name}'
                          : 'Bienvenido al portal',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: active
                            ? const Color(0xFF064E3B).withOpacity(0.55)
                            : AppColors.bgElevated,
                        border: Border.all(
                          color: active
                              ? AppColors.teal.withOpacity(0.4)
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        active
                            ? '✦  Activo · ${user!.daysRemaining} días restantes'
                            : 'Plan Gratuito · Funciones básicas',
                        style: GoogleFonts.inter(
                          color: active
                              ? const Color(0xFF6EE7B7)
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Consulta tarot, horóscopo, limpiezas espirituales, rituales y guías privadas desde una experiencia profesional y exclusiva.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  onPressed: () => _open(context, const TarotScreen()),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Iniciar Tarot',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlineButton(
                  onPressed: () => _launchWhatsApp(
                    message:
                        'Hola, quiero hablar con el maestro sobre un servicio.',
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.support_agent_rounded,
                              color: AppColors.primaryLight, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Consultar',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SECTION HEADER ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.gold, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(subtitle, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────
  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _drawerOpen(BuildContext context, Widget screen) {
    _scaffoldKey.currentState?.closeDrawer();
    _open(context, screen);
  }

  // ─── DRAWER ─────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, UserModel? user) {
    return Drawer(
      backgroundColor: AppColors.bgElevated,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A0000), Color(0xFF111111)],
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.borderGold, width: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF5C0000), Color(0xFF1A0000)],
                    ),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.55), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.auto_awesome, color: AppColors.gold, size: 36),
                ),
                const SizedBox(height: 14),
                Text(user?.name ?? 'Invitado', style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text(
                  user?.isMembershipActive == true
                      ? '✦  ACTIVO · ${user!.daysRemaining} días'
                      : 'PORTAL PREMIUM',
                  style: AppTextStyles.labelGold,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Perfil',
                    onTap: () =>
                        _drawerOpen(context, const PerfilScreen())),
                _DrawerItem(
                    icon: Icons.star_outline,
                    title: 'Horóscopo',
                    onTap: () =>
                        _drawerOpen(context, const HoroscopoScreen())),
                _DrawerItem(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Tarot',
                    onTap: () =>
                        _drawerOpen(context, const TarotScreen())),
                _DrawerItem(
                    icon: Icons.water_drop_outlined,
                    title: 'Limpiezas',
                    onTap: () =>
                        _drawerOpen(context, const LimpiezasScreen())),
                _DrawerItem(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Rituales',
                    onTap: () =>
                        _drawerOpen(context, const RitualesScreen())),
                _DrawerItem(
                    icon: Icons.person_pin_rounded,
                    title: 'El Maestro',
                    onTap: () =>
                        _drawerOpen(context, const MaestroScreen())),
                if (user?.role == 'admin')
                  _DrawerItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Administración',
                      onTap: () =>
                          _drawerOpen(context, const AdminDashboard())),
              ],
            ),
          ),
          // Logout
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.crimson.withOpacity(0.4)),
              color: AppColors.crimson.withOpacity(0.07),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: AppColors.crimsonLight, size: 20),
              title: Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  color: AppColors.crimsonLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                await Provider.of<AuthService>(context, listen: false)
                    .signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SERVICE CARD
// ─────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color accentColor;
  final String? badgeText;
  final Color? badgeTextColor;
  final Color? badgeColor;
  final Color? badgeBorderColor;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    this.badgeText,
    this.badgeTextColor,
    this.badgeColor,
    this.badgeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: accentColor.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: accentColor.withOpacity(0.28)),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.22),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Abrir',
                        style: GoogleFonts.inter(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          color: accentColor, size: 13),
                    ],
                  ),
                ],
              ),
              if (badgeText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: badgeBorderColor ?? AppColors.gold.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.inter(
                        color: badgeTextColor ?? AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
}

// ─────────────────────────────────────────────
// PREMIUM ACTION PANEL
// ─────────────────────────────────────────────
class _PremiumActionPanel extends StatelessWidget {
  final VoidCallback onTarot;
  final VoidCallback onContact;

  const _PremiumActionPanel(
      {required this.onTarot, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0000), Color(0xFF0D0000)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ruta Recomendada',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StepLine(
              number: '1',
              text: 'Revisa tu horóscopo y energía del día'),
          _StepLine(
              number: '2',
              text: 'Realiza una lectura de tarot guiada'),
          _StepLine(
              number: '3',
              text: 'Consulta limpieza o ritual recomendado'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  onPressed: onTarot,
                  child: Text(
                    'Comenzar',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlineButton(
                  onPressed: onContact,
                  child: Text(
                    'Maestro',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final String number;
  final String text;

  const _StepLine({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.gold, Color(0xFFB8860B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.cinzel(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER ITEM
// ─────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading:
          Icon(icon, color: AppColors.primaryLight, size: 20),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

// ─── Carta del Día ────────────────────────────────────────────────────────────
class _CartaDelDia extends StatelessWidget {
  static const _cartas = [
    {'nombre': 'El Mago', 'numero': 'I', 'mensaje': 'Hoy tienes el poder de manifestar tus deseos. Actúa con intención y confianza.', 'simbolo': '🌟'},
    {'nombre': 'La Sacerdotisa', 'numero': 'II', 'mensaje': 'Escucha tu intuición hoy. Las respuestas que buscas ya están en tu interior.', 'simbolo': '🌙'},
    {'nombre': 'La Emperatriz', 'numero': 'III', 'mensaje': 'Día de abundancia y creatividad. Nutre tus proyectos y relaciones con amor.', 'simbolo': '🌿'},
    {'nombre': 'El Emperador', 'numero': 'IV', 'mensaje': 'Toma el control de tu vida hoy. Tu disciplina y determinación son tus fortalezas.', 'simbolo': '👑'},
    {'nombre': 'El Sumo Sacerdote', 'numero': 'V', 'mensaje': 'Busca consejo sabio hoy. La tradición y la espiritualidad te guiarán.', 'simbolo': '✨'},
    {'nombre': 'Los Enamorados', 'numero': 'VI', 'mensaje': 'Día de decisiones importantes en el amor. Sigue tu corazón con valentía.', 'simbolo': '❤️'},
    {'nombre': 'El Carro', 'numero': 'VII', 'mensaje': 'Avanza con determinación. Hoy los obstáculos se apartan ante tu voluntad.', 'simbolo': '⚡'},
    {'nombre': 'La Fuerza', 'numero': 'VIII', 'mensaje': 'Tu fuerza interior es tu mayor recurso. Enfrenta los desafíos con calma.', 'simbolo': '🦁'},
    {'nombre': 'El Ermitaño', 'numero': 'IX', 'mensaje': 'Tómate un momento de silencio y reflexión. La sabiduría llega en la quietud.', 'simbolo': '🕯️'},
    {'nombre': 'La Rueda', 'numero': 'X', 'mensaje': 'El destino gira a tu favor. Los ciclos cambian y nuevas oportunidades llegan.', 'simbolo': '☯️'},
    {'nombre': 'La Justicia', 'numero': 'XI', 'mensaje': 'La verdad y el equilibrio prevalecen hoy. Actúa con honestidad en todo.', 'simbolo': '⚖️'},
    {'nombre': 'El Colgado', 'numero': 'XII', 'mensaje': 'Pausa y observa desde otra perspectiva. El sacrificio temporal trae revelación.', 'simbolo': '💧'},
    {'nombre': 'La Muerte', 'numero': 'XIII', 'mensaje': 'Una etapa termina para que algo mejor comience. Acepta la transformación.', 'simbolo': '🦋'},
    {'nombre': 'La Templanza', 'numero': 'XIV', 'mensaje': 'Busca el equilibrio y la moderación. La paciencia hoy te lleva a grandes logros.', 'simbolo': '🌊'},
    {'nombre': 'El Diablo', 'numero': 'XV', 'mensaje': 'Identifica qué te encadena. Hoy tienes el poder de liberarte de esas ataduras.', 'simbolo': '🔥'},
    {'nombre': 'La Torre', 'numero': 'XVI', 'mensaje': 'Los cambios súbitos son liberadores. Lo que cae estaba construido sobre base falsa.', 'simbolo': '⚡'},
    {'nombre': 'La Estrella', 'numero': 'XVII', 'mensaje': 'Día de esperanza y renovación. El universo conspira a tu favor hoy.', 'simbolo': '⭐'},
    {'nombre': 'La Luna', 'numero': 'XVIII', 'mensaje': 'Presta atención a tus sueños e intuiciones. Lo oculto se revela hoy.', 'simbolo': '🌕'},
    {'nombre': 'El Sol', 'numero': 'XIX', 'mensaje': 'Día de éxito, alegría y claridad. Tu luz interior brilla con fuerza hoy.', 'simbolo': '☀️'},
    {'nombre': 'El Juicio', 'numero': 'XX', 'mensaje': 'Es tiempo de un nuevo comienzo. Responde al llamado de tu propósito de vida.', 'simbolo': '🎺'},
    {'nombre': 'El Mundo', 'numero': 'XXI', 'mensaje': 'Completitud y éxito. Estás exactamente donde debes estar. Celebra tus logros.', 'simbolo': '🌍'},
    {'nombre': 'El Loco', 'numero': '0', 'mensaje': 'Día de nuevos inicios. Da el salto de fe. El universo te sostiene.', 'simbolo': '🎭'},
  ];

  @override
  Widget build(BuildContext context) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final carta = _cartas[dayOfYear % _cartas.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0000).withOpacity(0.92),
            const Color(0xFF080808).withOpacity(0.96),
          ],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Carta visual
          Container(
            width: 68,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D0000), Color(0xFF1A0000), Color(0xFF080808)],
              ),
              border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  carta['simbolo']!,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  carta['numero']!,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFD4A017),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Mensaje
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD4A017), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'CARTA DEL DÍA',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFD4A017),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  carta['nombre']!,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  carta['mensaje']!,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

