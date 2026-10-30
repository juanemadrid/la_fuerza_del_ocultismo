import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../models/tarot_card_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mysterious_page_route.dart';
import '../widgets/card_detail_dialog.dart';
import 'admin/admin_dashboard.dart';
import 'horoscopo_screen.dart';
import 'limpiezas_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'rituales_screen.dart';
import 'maestro_screen.dart';
import 'tarot_screen.dart';
import 'chat_maestro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.dailyCards});

  final Stream<List<TarotCardModel>>? dailyCards;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchWhatsApp({String? message}) async {
    try {
      final link = await DatabaseService().getWhatsAppLink();
      if (link.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'El enlace de WhatsApp no está configurado por el administrador.'),
            ),
          );
        }
        return;
      }
      final suffix =
          message == null ? '' : '?text=${Uri.encodeComponent(message)}';
      final url = Uri.parse('$link$suffix');
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('No se pudo abrir WhatsApp');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se pudo abrir WhatsApp. Verifica si la aplicación está instalada.'),
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
        decoration:
            const BoxDecoration(gradient: AppGradients.backgroundRadial),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 112),
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 24),
                  LayoutBuilder(builder: (context, constraints) {
                    final introduction = Column(children: [
                      _buildHero(context, user),
                      _CartaDelDia(cards: widget.dailyCards),
                    ]);
                    final services = Column(children: [
                      _buildSectionHeader('Tu espacio espiritual',
                          'Elige un camino y explora a tu ritmo'),
                      MysticServicesCircle(
                          user: user,
                          onOpen: (screen) => _open(context, screen)),
                    ]);
                    if (constraints.maxWidth < 900) {
                      return Column(children: [introduction, services]);
                    }
                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: introduction),
                          Expanded(child: services)
                        ]);
                  }),
                  const SizedBox(height: 24),
                  _PremiumActionPanel(
                    onTarot: () => _open(context, const TarotScreen()),
                    onContact: () => _launchWhatsApp(
                        message:
                            'Hola, quiero una orientación personalizada sobre tarot, limpieza o ritual.'),
                  ),
                ],
              ),
            ),
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
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MediaQuery.sizeOf(context).width < 600
          ? FloatingActionButton(
              tooltip: 'Chat con el Maestro',
              onPressed: () => _open(context, const ChatMaestroScreen()),
              backgroundColor: AppColors.primary,
              child:
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white),
            )
          : FloatingActionButton.extended(
              onPressed: () => _open(context, const ChatMaestroScreen()),
              backgroundColor: AppColors.primary,
              elevation: 0,
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: const Text(
                'Chat con el Maestro',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
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
              tooltip: 'Abrir menú',
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LA FUERZA DEL OCULTISMO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  user?.zodiacSign.isNotEmpty == true
                      ? 'Portal místico · ${user!.zodiacSign}'
                      : 'Portal del ocultismo',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textMuted,
                      fontSize: 11),
                ),
              ],
            ),
          ),
          if (user?.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded,
                  color: AppColors.gold),
              onPressed: () => _open(context, const AdminDashboard()),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded,
                color: AppColors.primaryLight),
            tooltip: 'Mi perfil',
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
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
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
                      color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
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
                            ? const Color(0xFF064E3B).withValues(alpha: 0.55)
                            : AppColors.bgElevated,
                        border: Border.all(
                          color: active
                              ? AppColors.teal.withValues(alpha: 0.4)
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        active
                            ? '✦  Activo · ${user!.daysRemaining} días restantes'
                            : 'Plan Gratuito · Funciones básicas',
                        style: TextStyle(
                          fontFamily: 'Inter',
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
            'Un momento para ti. Una nueva perspectiva.',
            style: AppTextStyles.displayLarge
                .copyWith(fontSize: 28, letterSpacing: 0.2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Explora el tarot, descubre tu horóscopo y encuentra orientación para tu camino espiritual.',
            style: TextStyle(
              fontFamily: 'Inter',
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
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Iniciar Tarot',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
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
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.support_agent_rounded,
                              color: AppColors.primaryLight, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontFamily: 'Inter',
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
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
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
              Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
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
    Navigator.push(context, MysteriousPageRoute(child: screen));
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
                        color: AppColors.gold.withValues(alpha: 0.55),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.gold, size: 36),
                ),
                const SizedBox(height: 14),
                Text(user?.name ?? 'Invitado',
                    style: AppTextStyles.titleMedium),
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
                    onTap: () => _drawerOpen(context, const PerfilScreen())),
                _DrawerItem(
                    icon: Icons.star_outline,
                    title: 'Horóscopo',
                    onTap: () => _drawerOpen(context, const HoroscopoScreen())),
                _DrawerItem(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Tarot',
                    onTap: () => _drawerOpen(context, const TarotScreen())),
                _DrawerItem(
                    icon: Icons.water_drop_outlined,
                    title: 'Limpiezas',
                    onTap: () => _drawerOpen(context, const LimpiezasScreen())),
                _DrawerItem(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Rituales',
                    onTap: () => _drawerOpen(context, const RitualesScreen())),
                _DrawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat con el Maestro',
                    onTap: () =>
                        _drawerOpen(context, const ChatMaestroScreen())),
                _DrawerItem(
                    icon: Icons.person_pin_rounded,
                    title: 'El Maestro',
                    onTap: () => _drawerOpen(context, const MaestroScreen())),
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
              border:
                  Border.all(color: AppColors.crimson.withValues(alpha: 0.4)),
              color: AppColors.crimson.withValues(alpha: 0.07),
            ),
            child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded,
                      color: AppColors.crimsonLight, size: 20),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontFamily: 'Inter',
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
                )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RUEDA / CÍRCULO MÍSTICO DE SERVICIOS ESPIRITUALES
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceNodeData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String rune;
  final Gradient gradient;
  final Color accentColor;
  final String? badgeText;
  final Color? badgeTextColor;
  final Color? badgeColor;
  final Color? badgeBorderColor;
  final VoidCallback onTap;

  const _ServiceNodeData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rune,
    required this.gradient,
    required this.accentColor,
    this.badgeText,
    this.badgeTextColor,
    this.badgeColor,
    this.badgeBorderColor,
    required this.onTap,
  });
}

class MysticServicesCircle extends StatefulWidget {
  final UserModel? user;
  final void Function(Widget screen) onOpen;

  const MysticServicesCircle({
    super.key,
    required this.user,
    required this.onOpen,
  });

  @override
  State<MysticServicesCircle> createState() => _MysticServicesCircleState();
}

class _MysticServicesCircleState extends State<MysticServicesCircle>
    with TickerProviderStateMixin {
  // Giro constante de los recuadros alrededor del sello (una vuelta cada 28 s).
  late final AnimationController _orbitCtrl;
  // Pulso suave de brillo del sello y del humo.
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Ángulo de cada recuadro sobre la órbita. Arrancan en las diagonales
  /// (arriba-izquierda, arriba-derecha, abajo-derecha, abajo-izquierda) y
  /// giran juntos en sentido horario.
  static double cardAngle(double orbit, int index) =>
      orbit * 2 * math.pi - (3 * math.pi / 4) + index * (math.pi / 2);

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.user?.isMembershipActive == true;

    final services = <_ServiceNodeData>[
      _ServiceNodeData(
        icon: Icons.auto_awesome_rounded,
        title: 'Tarot',
        subtitle: 'Pasado, presente y futuro',
        rune: 'ᚠ',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF281517), Color(0xFF11090A)],
        ),
        accentColor: AppColors.gold,
        badgeText: isPremium ? 'PREMIUM' : 'GRATIS',
        badgeTextColor: isPremium ? const Color(0xFF34D399) : AppColors.gold,
        badgeColor:
            isPremium ? const Color(0x3034D399) : const Color(0x25D4AF37),
        badgeBorderColor:
            isPremium ? const Color(0x6034D399) : const Color(0x60D4AF37),
        onTap: () => widget.onOpen(const TarotScreen()),
      ),
      _ServiceNodeData(
        icon: Icons.stars_rounded,
        title: 'Horóscopo',
        subtitle: 'Predicción y energía astral',
        rune: 'ᚢ',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21142E), Color(0xFF0E0915)],
        ),
        accentColor: const Color(0xFFC084FC),
        badgeText: isPremium ? 'PREMIUM' : '1 GRATIS',
        badgeTextColor:
            isPremium ? const Color(0xFF34D399) : const Color(0xFFC084FC),
        badgeColor:
            isPremium ? const Color(0x3034D399) : const Color(0x25C084FC),
        badgeBorderColor:
            isPremium ? const Color(0x6034D399) : const Color(0x60C084FC),
        onTap: () => widget.onOpen(const HoroscopoScreen()),
      ),
      _ServiceNodeData(
        icon: Icons.local_fire_department_rounded,
        title: 'Rituales',
        subtitle: 'Amor, dinero y caminos',
        rune: 'ᚨ',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1013), Color(0xFF140607)],
        ),
        accentColor: const Color(0xFFF87171),
        badgeText: 'PODER',
        badgeTextColor: const Color(0xFFF87171),
        badgeColor: const Color(0x22F87171),
        badgeBorderColor: const Color(0x55F87171),
        onTap: () => widget.onOpen(const RitualesScreen()),
      ),
      _ServiceNodeData(
        icon: Icons.water_drop_rounded,
        title: 'Limpiezas',
        subtitle: 'Cuerpo, hogar y protección',
        rune: 'ᚦ',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2826), Color(0xFF071413)],
        ),
        accentColor: const Color(0xFF2DD4BF),
        badgeText: 'PUREZA',
        badgeTextColor: const Color(0xFF2DD4BF),
        badgeColor: const Color(0x222DD4BF),
        badgeBorderColor: const Color(0x552DD4BF),
        onTap: () => widget.onOpen(const LimpiezasScreen()),
      ),
    ];
    final accents = services.map((s) => s.accentColor).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 600.0);
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
      // Ancho del recuadro calculado para que dos recuadros vecinos nunca se
      // monten uno sobre otro mientras giran, incluso en celulares angostos.
      final cardW = (width * 0.40).clamp(118.0, 200.0);
      final cardH = largeText ? 150.0 : 102.0;
      final rx = math.max(40.0, (width - cardW) / 2 - 4);
      final ry = largeText ? 185.0 : 150.0;
      final height = ry * 2 + cardH + 12;

      return Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(children: [
            // Capa estática (resplandor de fondo): se pinta una sola vez.
            Positioned.fill(
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: CustomPaint(
                      painter: _StaticGlowPainter(rx: rx, ry: ry)),
                ),
              ),
            ),
            // Capa animada: humo, sello y recuadros girando.
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_orbitCtrl, _pulseCtrl]),
                  builder: (context, _) {
                    final orbit = _orbitCtrl.value;
                    final pulse = _pulseCtrl.value;
                    final cx = width / 2;
                    final cy = height / 2;
                    final centers = List<Offset>.generate(4, (i) {
                      final a = cardAngle(orbit, i);
                      return Offset(
                          cx + rx * math.cos(a), cy + ry * math.sin(a));
                    });
                    return Stack(children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _ArcaneCirclePainter(
                              orbit: orbit,
                              pulse: pulse,
                              rx: rx,
                              ry: ry,
                              cardCenters: centers,
                              accentColors: accents,
                            ),
                          ),
                        ),
                      ),
                      for (int i = 0; i < services.length; i++)
                        Positioned(
                          left: centers[i].dx - cardW / 2,
                          top: centers[i].dy - cardH / 2,
                          width: cardW,
                          height: cardH,
                          child: _CompactServiceCard(
                            data: services[i],
                            // Brilla más el recuadro que pasa por arriba.
                            highlightIntensity: ((1.0 -
                                        math.sin(cardAngle(orbit, i))) *
                                    0.5)
                                .clamp(0.0, 1.0),
                            pulse: pulse,
                          ),
                        ),
                    ]);
                  },
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPLANDOR ESTÁTICO DE FONDO (se dibuja una vez, no en cada cuadro)
// ─────────────────────────────────────────────────────────────────────────────
class _StaticGlowPainter extends CustomPainter {
  final double rx;
  final double ry;
  const _StaticGlowPainter({required this.rx, required this.ry});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.max(rx, ry) * 1.15;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF8B0000).withValues(alpha: 0.28),
            const Color(0xFFD4AF37).withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(covariant _StaticGlowPainter old) =>
      old.rx != rx || old.ry != ry;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTER DEL CÍRCULO RITUAL ARCANO + ESTELAS DE HUMO
// Solo usa colores sólidos con transparencia (sin shaders ni blur por cuadro):
// los gradientes creados 60 veces por segundo agotaban la memoria gráfica de
// los navegadores móviles y dejaban la pantalla en negro.
// ─────────────────────────────────────────────────────────────────────────────
class _ArcaneCirclePainter extends CustomPainter {
  final double orbit;
  final double pulse;
  final double rx;
  final double ry;
  final List<Offset> cardCenters;
  final List<Color> accentColors;

  _ArcaneCirclePainter({
    required this.orbit,
    required this.pulse,
    required this.rx,
    required this.ry,
    required this.cardCenters,
    required this.accentColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final orbitAngle = orbit * 2 * math.pi;
    final coreR = math.min(rx, ry) * 0.54;

    // 1. Bruma suave detrás del sello (anillos concéntricos translúcidos)
    final mistR = coreR * (1.25 + 0.12 * math.sin(orbitAngle * 2));
    for (int k = 3; k >= 1; k--) {
      canvas.drawCircle(
        center,
        mistR * (k / 3),
        Paint()
          ..color = const Color(0xFF8B0000)
              .withValues(alpha: 0.06 + 0.03 * pulse),
      );
    }

    // 2. Anillo orbital por donde giran los recuadros
    final orbitRect =
        Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      orbitRect,
      Paint()
        ..color =
            const Color(0xFFB71C1C).withValues(alpha: 0.14 + 0.08 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0,
    );
    canvas.drawOval(
      orbitRect,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.28 + 0.08 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // 3. Estelas de humo detrás de cada recuadro (cola de cometa)
    for (int i = 0; i < 4; i++) {
      final a = _MysticServicesCircleState.cardAngle(orbit, i);
      final color = accentColors[i];
      const int wispCount = 9;
      for (int w = 1; w <= wispCount; w++) {
        final f = w / wispCount;
        // El humo queda atrás del recuadro según el sentido del giro.
        final ta = a - f * 0.85;
        final wobble =
            math.sin(orbitAngle * 3.2 + w * 1.4 + i * 2.0) * (3 + 6 * f);
        final wx = cx + (rx + wobble) * math.cos(ta);
        final wy = cy + (ry + wobble) * math.sin(ta) - f * 10;
        final wc = Offset(wx, wy);
        final baseR = 10.0 + f * 26.0;
        final alpha = ((1.0 - f) * (0.20 + 0.10 * pulse)).clamp(0.0, 0.35);

        // Voluta: tres capas translúcidas simulan el difuminado del humo.
        canvas.drawCircle(
            wc, baseR, Paint()..color = color.withValues(alpha: alpha * 0.35));
        canvas.drawCircle(wc, baseR * 0.66,
            Paint()..color = color.withValues(alpha: alpha * 0.55));
        canvas.drawCircle(
            wc,
            baseR * 0.33,
            Paint()
              ..color = const Color(0xFF2A0306).withValues(alpha: alpha * 0.6));

        // Brasas que titilan dentro del humo
        if (w.isOdd) {
          final ew = math.cos(orbitAngle * 4.5 + w * 2.3) * 4.0;
          canvas.drawCircle(
            Offset(wx + ew, wy - ew * 0.6),
            1.1 + 0.8 * (1.0 - f),
            Paint()
              ..color = (w == 1 ? Colors.white : AppColors.gold).withValues(
                  alpha: ((1.0 - f * 0.75) * (0.5 + 0.35 * pulse))
                      .clamp(0.0, 0.9)),
          );
        }
      }

      // Arco luminoso que une el recuadro con su estela
      canvas.drawArc(
        orbitRect,
        a - 0.6,
        0.6,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.45 + 0.22 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Hilos de energía del núcleo a cada recuadro
    for (int i = 0; i < cardCenters.length; i++) {
      canvas.drawLine(
        center,
        cardCenters[i],
        Paint()
          ..color = accentColors[i].withValues(alpha: 0.24 + 0.10 * pulse)
          ..strokeWidth = 1.0,
      );
    }

    // 5. Doble anillo del sello central
    final outerSealR = coreR * 1.15;
    canvas.drawCircle(
      center,
      outerSealR,
      Paint()
        ..color =
            const Color(0xFFEF233C).withValues(alpha: 0.16 + 0.10 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawCircle(
      center,
      outerSealR,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.45 + 0.15 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawCircle(
      center,
      coreR * 0.88,
      Paint()
        ..color = const Color(0xFF8B0000).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Sellos girando
    const int sealCount = 12;
    for (int i = 0; i < sealCount; i++) {
      final sa = orbitAngle * 0.7 + i * 2 * math.pi / sealCount;
      canvas.drawCircle(
        Offset(cx + coreR * 1.01 * math.cos(sa),
            cy + coreR * 1.01 * math.sin(sa)),
        i % 3 == 0 ? 2.4 : 1.5,
        Paint()
          ..color = (i.isEven ? AppColors.gold : const Color(0xFFEF233C))
              .withValues(alpha: 0.55 + 0.25 * pulse),
      );
    }

    // 6. Pentagrama girando en sentido contrario
    final starR = coreR * 0.82;
    final starPts = List.generate(5, (i) {
      final sa = -orbitAngle * 1.1 + math.pi / 2 + i * 4 * math.pi / 5;
      return Offset(cx + starR * math.cos(sa), cy + starR * math.sin(sa));
    });
    final starPath = Path()..moveTo(starPts[0].dx, starPts[0].dy);
    for (int i = 1; i < 5; i++) {
      starPath.lineTo(starPts[i].dx, starPts[i].dy);
    }
    starPath.close();
    canvas.drawPath(
      starPath,
      Paint()
        ..color =
            const Color(0xFFB71C1C).withValues(alpha: 0.28 + 0.14 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    canvas.drawPath(
      starPath,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.55 + 0.20 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // 7. Ojo místico en el centro
    final eyeW = coreR * 0.38;
    final eyeH = coreR * (0.20 + 0.05 * pulse);
    final eyePath = Path()
      ..moveTo(cx - eyeW, cy)
      ..cubicTo(cx - eyeW * 0.45, cy - eyeH * 1.3, cx + eyeW * 0.45,
          cy - eyeH * 1.3, cx + eyeW, cy)
      ..cubicTo(cx + eyeW * 0.45, cy + eyeH * 1.3, cx - eyeW * 0.45,
          cy + eyeH * 1.3, cx - eyeW, cy)
      ..close();
    canvas.drawPath(eyePath, Paint()..color = const Color(0xFF090000));

    final irisR = eyeH * 0.78;
    canvas.drawCircle(center, irisR, Paint()..color = const Color(0xFF4A0000));
    canvas.drawCircle(
        center, irisR * 0.8, Paint()..color = const Color(0xFFEF233C));
    canvas.drawCircle(center, irisR * 0.35,
        Paint()..color = AppColors.gold.withValues(alpha: 0.85));
    canvas.drawOval(
      Rect.fromCenter(
          center: center, width: irisR * 0.36, height: irisR * 1.55),
      Paint()..color = Colors.black,
    );
    canvas.drawPath(
      eyePath,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcaneCirclePainter old) =>
      old.orbit != orbit || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// RECUADRO COMPACTO Y MISTERIOSO DE SERVICIO
// ─────────────────────────────────────────────────────────────────────────────
class _CompactServiceCard extends StatelessWidget {
  final _ServiceNodeData data;
  final double highlightIntensity;
  final double pulse;

  const _CompactServiceCard({
    required this.data,
    required this.highlightIntensity,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final borderOpacity =
        (0.38 + 0.42 * highlightIntensity + 0.10 * pulse).clamp(0.0, 1.0);
    final glowOpacity =
        (0.12 + 0.22 * highlightIntensity + 0.06 * pulse).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: data.gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: data.accentColor.withValues(alpha: borderOpacity),
              width: 1.15,
            ),
            // Una sola sombra con desenfoque fijo: más liviana en celulares.
            boxShadow: [
              BoxShadow(
                color: data.accentColor.withValues(alpha: glowOpacity),
                blurRadius: 12,
              ),
            ],
          ),
          child: SizedBox(
            child: Stack(
              children: [
                // Símbolo místico de marca de agua en la esquina
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Icon(
                    data.icon,
                    color: data.accentColor.withValues(alpha: 0.10),
                    size: 28,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fila superior: Icono pequeño + Badge + Flecha
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: data.accentColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: data.accentColor.withValues(alpha: 0.45),
                              width: 0.9,
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            color: data.accentColor,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (data.badgeText != null)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: data.badgeColor ??
                                      const Color(0x25D4AF37),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: data.badgeBorderColor ??
                                        const Color(0x60D4AF37),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  data.badgeText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color:
                                        data.badgeTextColor ?? AppColors.gold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.goldLight,
                          size: 10,
                        ),
                      ],
                    ),
                    // Título + subtítulo compacto
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          data.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white.withValues(alpha: 0.62),
                            fontSize: 12,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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

  const _PremiumActionPanel({required this.onTarot, required this.onContact});

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
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
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
              const Icon(Icons.route_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                'Ruta Recomendada',
                style:
                    AppTextStyles.titleMedium.copyWith(color: AppColors.gold),
              )),
            ],
          ),
          const SizedBox(height: 18),
          const _StepLine(
              number: '1', text: 'Revisa tu horóscopo y energía del día'),
          const _StepLine(
              number: '2', text: 'Realiza una lectura de tarot guiada'),
          const _StepLine(
              number: '3', text: 'Consulta limpieza o ritual recomendado'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  onPressed: onTarot,
                  child: const Text(
                    'Iniciar lectura',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
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
                  child: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontFamily: 'Inter',
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
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Cinzel',
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
              style: const TextStyle(
                fontFamily: 'Inter',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: AppColors.primaryLight, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
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
  final Stream<List<TarotCardModel>>? cards;
  const _CartaDelDia({this.cards});
  static const _cartas = [
    {
      'nombre': 'El Loco',
      'mensaje':
          'Día de nuevos inicios. Da el salto de fe. El universo te sostiene.',
      'orden': 0
    },
    {
      'nombre': 'El Mago',
      'mensaje':
          'Hoy tienes el poder de manifestar tus deseos. Actúa con intención y confianza.',
      'orden': 1
    },
    {
      'nombre': 'La Sacerdotisa',
      'mensaje':
          'Escucha tu intuición hoy. Las respuestas que buscas ya están en tu interior.',
      'orden': 2
    },
    {
      'nombre': 'La Emperatriz',
      'mensaje':
          'Día de abundancia y creatividad. Nutre tus proyectos y relaciones con amor.',
      'orden': 3
    },
    {
      'nombre': 'El Sacerdote',
      'mensaje':
          'Sabiduría tradicional, enseñanza, guía espiritual y valores establecidos.',
      'orden': 4
    },
    {
      'nombre': 'El Amor',
      'mensaje':
          'Elecciones importantes, amor, alineación de valores y relaciones.',
      'orden': 5
    },
    {
      'nombre': 'El Ermitaño',
      'mensaje':
          'Tómate un momento de silencio y reflexión. La sabiduría llega en la quietud.',
      'orden': 6
    },
    {
      'nombre': 'La Rueda de la Fortuna',
      'mensaje': 'Cambio, ciclos, destino y puntos de inflexión inesperados.',
      'orden': 7
    },
    {
      'nombre': 'La Fuerza',
      'mensaje':
          'Tu fuerza interior es tu mayor recurso. Enfrenta los desafíos con calma.',
      'orden': 8
    },
    {
      'nombre': 'La Muerte',
      'mensaje':
          'Una etapa termina para que algo mejor comience. Acepta la transformación.',
      'orden': 9
    },
    {
      'nombre': 'La Torre',
      'mensaje':
          'Los cambios súbitos son liberadores. Lo que cae estaba construido sobre base falsa.',
      'orden': 10
    },
    {
      'nombre': 'El Mundo',
      'mensaje':
          'Completitud y éxito. Estás exactamente donde debes estar. Celebra tus logros.',
      'orden': 11
    },
    {
      'nombre': 'El Bufón',
      'mensaje':
          'Diversión, ingenio, ironía y ver la vida desde otra perspectiva.',
      'orden': 12
    },
    {
      'nombre': 'El Camino',
      'mensaje': 'Dirección, elecciones de vida, sendero evolutivo y destino.',
      'orden': 13
    },
    {
      'nombre': 'El Duende',
      'mensaje':
          'Travesura, suerte inesperada, conexión con la naturaleza y magia elemental.',
      'orden': 14
    },
    {
      'nombre': 'El Miedo',
      'mensaje':
          'Bloqueos mentales, temores inconscientes y la necesidad de superarse.',
      'orden': 15
    },
    {
      'nombre': 'El Perdón',
      'mensaje':
          'Liberación de resentimientos, paz interior y sanación emocional.',
      'orden': 16
    },
    {
      'nombre': 'El Rey',
      'mensaje': 'Liderazgo, control, estabilidad, sabiduría y protección.',
      'orden': 17
    },
    {
      'nombre': 'El Viaje',
      'mensaje':
          'Movimiento, exploración, cambio de perspectiva y crecimiento personal.',
      'orden': 18
    },
    {
      'nombre': 'Gran Premio',
      'mensaje': 'Recompensa merecida, abundancia, éxito rotundo y fortuna.',
      'orden': 19
    },
    {
      'nombre': 'La Bruja',
      'mensaje':
          'Magia práctica, intuición profunda, conexión con lo sagrado femenino y sabiduría.',
      'orden': 20
    },
    {
      'nombre': 'La Envidia',
      'mensaje':
          'Celos, energías discordantes externas o internas, y la necesidad de autovaloración.',
      'orden': 21
    },
    {
      'nombre': 'La Ira',
      'mensaje':
          'Pasión desbordada, enojo acumulado y necesidad de transmutación.',
      'orden': 22
    },
    {
      'nombre': 'La Pobreza',
      'mensaje':
          'Mentalidad de escasez, dificultades temporales y necesidad de apoyo.',
      'orden': 23
    },
    {
      'nombre': 'La Reina',
      'mensaje':
          'Poder receptivo, intuición, empatía, madurez emocional y soberanía.',
      'orden': 24
    },
    {
      'nombre': 'La Traición',
      'mensaje':
          'Decepción, deslealtad, cortes dolorosos y aprendizaje de la confianza.',
      'orden': 25
    },
    {
      'nombre': 'Negocios',
      'mensaje':
          'Acuerdos comerciales, transacciones, alianzas de trabajo y éxito financiero.',
      'orden': 26
    },
    {
      'nombre': 'Oro',
      'mensaje':
          'Riqueza material, valor intrínseco, éxito sólido y prosperidad.',
      'orden': 27
    },
    {
      'nombre': 'Plata',
      'mensaje': 'Claridad mental, intuición, valor emocional y adaptabilidad.',
      'orden': 28
    },
    {
      'nombre': 'Reconciliación',
      'mensaje':
          'Unión de opuestos, sanación de relaciones, paz y armonía recobrada.',
      'orden': 29
    },
    {
      'nombre': 'Salud',
      'mensaje':
          'Bienestar físico, mental y espiritual, vitalidad y equilibrio orgánico.',
      'orden': 30
    },
    {
      'nombre': 'Sorpresa',
      'mensaje':
          'Eventos inesperados, regalos del destino y giros del destino.',
      'orden': 31
    },
    {
      'nombre': 'Suerte',
      'mensaje': 'Buena fortuna, sincronicidades favorables y viento a favor.',
      'orden': 32
    },
    {
      'nombre': 'Trabajo',
      'mensaje':
          'Esfuerzo constante, dedicación, desarrollo profesional y labor diaria.',
      'orden': 33
    },
    {
      'nombre': 'Ángel',
      'mensaje': 'Protección divina, guía celestial, pureza y mensajes de paz.',
      'orden': 34
    },
    {
      'nombre': 'Carta Negra',
      'mensaje':
          'Energías densas, advertencia, autoanálisis profundo y cautela.',
      'orden': 35
    },
    {
      'nombre': 'Carta Blanca',
      'mensaje':
          'Posibilidades infinitas, destino libre y poder de elección total.',
      'orden': 36
    },
    {
      'nombre': 'Dinero',
      'mensaje':
          'Flujo financiero, ingresos, transacciones económicas y seguridad material.',
      'orden': 37
    },
  ];

  Widget _buildCardSprite(int orden, String? imageUrl) {
    const double displayWidth = 68.0;
    const double displayHeight = 132.0;

    return Container(
      width: displayWidth,
      height: displayHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.borderGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A017).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/tarot/carta_$orden.png',
                  width: displayWidth,
                  height: displayHeight,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/images/tarot/carta_$orden.png',
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TarotCardModel>>(
      stream: cards ?? DatabaseService().streamTarotCards(),
      builder: (context, snapshot) {
        final dayOfYear = DateTime.now()
            .difference(DateTime(DateTime.now().year, 1, 1))
            .inDays;

        String name = 'El Loco';
        String message =
            'Día de nuevos inicios. Da el salto de fe. El universo te sostiene.';
        int orden = 0;
        String? imageUrl;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final databaseCards = snapshot.data!;
          final dbCard = databaseCards[dayOfYear % databaseCards.length];
          name = dbCard.nombre;
          message = dbCard.significado;
          orden = dbCard.orden;
          imageUrl = dbCard.imageUrl;
        } else {
          final carta = _cartas[dayOfYear % _cartas.length];
          name = carta['nombre'] as String;
          message = carta['mensaje'] as String;
          orden = carta['orden'] as int;
        }

        return GestureDetector(
          onTap: () {
            CardDetailDialog.show(
              context,
              nombre: name,
              significado: message,
              orden: orden,
              imageUrl: imageUrl,
              subtitle: 'CARTA DEL DÍA',
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A0000).withValues(alpha: 0.92),
                  const Color(0xFF080808).withValues(alpha: 0.96),
                ],
              ),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardSprite(orden, imageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Color(0xFFD4A017), size: 14),
                          SizedBox(width: 6),
                          Expanded(
                              child: Text(
                            'CARTA DEL DÍA',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              color: Color(0xFFD4A017),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Ver interpretación →',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.goldLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
