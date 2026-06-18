import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_container.dart';

class HoroscopoScreen extends StatefulWidget {
  const HoroscopoScreen({super.key});

  @override
  State<HoroscopoScreen> createState() => _HoroscopoScreenState();
}

class _HoroscopoScreenState extends State<HoroscopoScreen>
    with SingleTickerProviderStateMixin {
  String? _signoSeleccionado;
  String _prediccion = '';
  bool _isLoading = false;
  bool _isSignLocked = false;

  int _currentTab = 0;
  String? _signo1;
  String? _signo2;
  Map<String, dynamic>? _resultadoCompatibilidad;

  final List<Map<String, dynamic>> _signos = [
    {'nombre': 'Aries',       'icono': '♈', 'fechas': 'Mar 21 – Abr 19'},
    {'nombre': 'Tauro',       'icono': '♉', 'fechas': 'Abr 20 – May 20'},
    {'nombre': 'Géminis',     'icono': '♊', 'fechas': 'May 21 – Jun 20'},
    {'nombre': 'Cáncer',      'icono': '♋', 'fechas': 'Jun 21 – Jul 22'},
    {'nombre': 'Leo',         'icono': '♌', 'fechas': 'Jul 23 – Ago 22'},
    {'nombre': 'Virgo',       'icono': '♍', 'fechas': 'Ago 23 – Sep 22'},
    {'nombre': 'Libra',       'icono': '♎', 'fechas': 'Sep 23 – Oct 22'},
    {'nombre': 'Escorpio',    'icono': '♏', 'fechas': 'Oct 23 – Nov 21'},
    {'nombre': 'Sagitario',   'icono': '♐', 'fechas': 'Nov 22 – Dic 21'},
    {'nombre': 'Capricornio', 'icono': '♑', 'fechas': 'Dic 22 – Ene 19'},
    {'nombre': 'Acuario',     'icono': '♒', 'fechas': 'Ene 20 – Feb 18'},
    {'nombre': 'Piscis',      'icono': '♓', 'fechas': 'Feb 19 – Mar 20'},
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
        _signo1 = user.zodiacSign;
        _isSignLocked = true;
      });
      if (user.isMembershipActive) {
        _cargarPrediccion(user.zodiacSign);
      }
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
    if (user == null || !user.isMembershipActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitas una suscripción activa para consultar el horóscopo',
            style: GoogleFonts.inter(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_signoSeleccionado != null) {
      _cargarPrediccion(_signoSeleccionado!);
    }
  }

  void _calcularCompatibilidad() {
    if (_signo1 == null || _signo2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor selecciona ambos signos zodiacales',
            style: GoogleFonts.inter(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final el1 = _obtenerElemento(_signo1!);
    final el2 = _obtenerElemento(_signo2!);

    int amor = 50, amistad = 50, trabajo = 50;
    String descripcion = '';

    if (el1 == el2) {
      switch (el1) {
        case 'Fuego':
          amor = 90; amistad = 85; trabajo = 75;
          descripcion = 'Fuego con Fuego: Una combinación explosiva, apasionada y sumamente dinámica. Comparten entusiasmo desbordante y gran ambición, aunque deben cuidar los choques de ego. La chispa nunca se apagará.';
          break;
        case 'Tierra':
          amor = 85; amistad = 90; trabajo = 95;
          descripcion = 'Tierra con Tierra: Estabilidad pura. Esta relación es sólida como una roca, práctica y enfocada en construir bases firmes para el futuro. El único riesgo es caer en la monotonía.';
          break;
        case 'Aire':
          amor = 78; amistad = 92; trabajo = 88;
          descripcion = 'Aire con Aire: Unión altamente intelectual, estimulante y llena de conversaciones profundas. Aman la libertad personal, aunque puede faltarles conexión emocional profunda.';
          break;
        case 'Agua':
          amor = 95; amistad = 88; trabajo = 70;
          descripcion = 'Agua con Agua: Empatía absoluta y conexión espiritual sin palabras. Se entienden emocionalmente de manera casi mágica. El exceso de sensibilidad puede crear tormentas internas.';
          break;
      }
    } else {
      final combinacion = '${el1}_$el2';
      final combinacionInversa = '${el2}_$el1';

      if (combinacion == 'Fuego_Aire' || combinacionInversa == 'Fuego_Aire') {
        amor = 88; amistad = 85; trabajo = 80;
        descripcion = 'Fuego y Aire: El aire aviva el fuego. Relación llena de inspiración, proyectos conjuntos y energía constante. Se motivan mutuamente de manera excepcional.';
      } else if (combinacion == 'Fuego_Tierra' || combinacionInversa == 'Fuego_Tierra') {
        amor = 62; amistad = 68; trabajo = 82;
        descripcion = 'Fuego y Tierra: La tierra le da estructura al fuego inquieto, mientras el fuego inyecta dinamismo. Funciona bien a nivel profesional, pero en lo amoroso requiere paciencia.';
      } else if (combinacion == 'Fuego_Agua' || combinacionInversa == 'Fuego_Agua') {
        amor = 48; amistad = 55; trabajo = 50;
        descripcion = 'Fuego y Agua: Fuerzas opuestas primordiales. Tienen una fuerte atracción por ser opuestos, pero exige un enorme esfuerzo de adaptación mutua.';
      } else if (combinacion == 'Tierra_Agua' || combinacionInversa == 'Tierra_Agua') {
        amor = 92; amistad = 88; trabajo = 85;
        descripcion = 'Tierra y Agua: El agua nutre la tierra, permitiendo que florezcan proyectos y sentimientos estables. Unión sumamente enriquecedora y pacífica.';
      } else if (combinacion == 'Tierra_Aire' || combinacionInversa == 'Tierra_Aire') {
        amor = 55; amistad = 70; trabajo = 78;
        descripcion = 'Tierra y Aire: El aire vive en el mundo de las ideas, la tierra necesita hechos concretos. Funciona bien en proyectos, pero en lo sentimental les cuesta sintonizar.';
      } else if (combinacion == 'Aire_Agua' || combinacionInversa == 'Aire_Agua') {
        amor = 50; amistad = 72; trabajo = 65;
        descripcion = 'Aire y Agua: El aire racionaliza mientras el agua siente de manera intuitiva. Necesitan construir un puente fuerte de entendimiento verbal.';
      }
    }

    final global = ((amor + amistad + trabajo) / 3).round();
    setState(() {
      _resultadoCompatibilidad = {
        'global': global,
        'amor': amor,
        'amistad': amistad,
        'trabajo': trabajo,
        'descripcion': descripcion,
      };
    });
  }

  String _obtenerElemento(String signo) {
    switch (signo) {
      case 'Aries': case 'Leo': case 'Sagitario': return 'Fuego';
      case 'Tauro': case 'Virgo': case 'Capricornio': return 'Tierra';
      case 'Géminis': case 'Libra': case 'Acuario': return 'Aire';
      default: return 'Agua';
    }
  }

  // ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    
    // Dynamically detect user sign if it was loaded asynchronously
    if (user != null && user.zodiacSign.isNotEmpty && _signoSeleccionado == null) {
      _signoSeleccionado = user.zodiacSign;
      _signo1 = user.zodiacSign;
      _isSignLocked = true;
      if (user.isMembershipActive && _prediccion.isEmpty && !_isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _cargarPrediccion(user.zodiacSign);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundRadial),
        child: ResponsiveContainer(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tabs ──────────────────────────────────
                _buildTabs(),
                const SizedBox(height: 28),

                if (_currentTab == 0)
                  _buildPrediccionTab(user)
                else
                  _buildCompatibilidadTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgBase,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.primaryLight, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [AppColors.gold, AppColors.primaryLight],
        ).createShader(bounds),
        child: Text(
          'HORÓSCOPO',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              AppColors.borderGold,
              Colors.transparent
            ]),
          ),
        ),
      ),
    );
  }

  // ── TABS ─────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton(0, 'Predicción', Icons.auto_awesome_rounded),
          _buildTabButton(1, 'Compatibilidad', Icons.favorite_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final active = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active ? AppGradients.primaryButton : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: active ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  color: active ? Colors.white : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAB: PREDICCIÓN ──────────────────────────────────
  Widget _buildPrediccionTab(user) {
    if (_isSignLocked) {
      final userSign = user?.zodiacSign ?? '';
      final signoData = _signos.firstWhere(
        (s) => s['nombre'] == userSign,
        orElse: () => {'icono': '🔮', 'nombre': userSign, 'fechas': ''},
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppGradients.heroCard,
              border: Border.all(color: AppColors.borderGold),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                  ),
                  child: Text(
                    signoData['icono'] as String,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Horóscopo Personalizado',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userSign.toUpperCase(),
                        style: AppTextStyles.displayLarge.copyWith(fontSize: 22, color: AppColors.gold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        signoData['fechas'] as String,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (user != null && !user.isMembershipActive) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Contenido Protegido',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activa tu suscripción para desbloquear el horóscopo y recibir la predicción diaria del Maestro Leyson.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_prediccion.isNotEmpty)
              _buildPrediccionResult()
            else
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'No se pudo cargar la predicción.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _cargarPrediccion(userSign),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona tu Signo Zodiacal', style: AppTextStyles.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Elige el signo para ver tu predicción',
          style: AppTextStyles.bodySmall,
        ),

        if (user != null && !user.isMembershipActive)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Activa tu suscripción para desbloquear el horóscopo personalizado.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ),

        const SizedBox(height: 24),

        // ── Grid de signos
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: _signos.length,
          itemBuilder: (context, index) {
            final signo = _signos[index];
            final isSelected = _signoSeleccionado == signo['nombre'];
            return _ZodiacCard(
              signo: signo,
              isSelected: isSelected,
              isLocked: _isSignLocked,
              onTap: () {
                if (_isSignLocked) return;
                setState(() {
                  _signoSeleccionado = signo['nombre'] as String;
                  _prediccion = '';
                });
              },
            );
          },
        ),

        const SizedBox(height: 28),

        // Botón consultar
        if (_signoSeleccionado != null)
          GlowButton(
            onPressed: (_isLoading ||
                    (user != null && !user.isMembershipActive))
                ? null
                : _generarPrediccion,
            height: 58,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 17),
                      const SizedBox(width: 10),
                      Text(
                        'Consultar Horóscopo',
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),

        // Predicción resultado
        if (_prediccion.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildPrediccionResult(),
        ],
      ],
    );
  }

  Widget _buildPrediccionResult() {
    final signoData = _signos.firstWhere(
      (s) => s['nombre'] == _signoSeleccionado,
      orElse: () => {'icono': '✦', 'nombre': _signoSeleccionado ?? ''},
    );

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1040), Color(0xFF0F0D1A)],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            signoData['icono'] as String,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) => const LinearGradient(
              colors: [AppColors.gold, AppColors.primaryLight],
            ).createShader(b),
            child: Text(
              'Tu Horóscopo · $_signoSeleccionado',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 50,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.borderGold, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _prediccion,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── TAB: COMPATIBILIDAD ───────────────────────────────
  Widget _buildCompatibilidadTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compatibilidad Zodiacal', style: AppTextStyles.titleLarge),
        const SizedBox(height: 6),
        Text('Calcula la afinidad entre dos signos', style: AppTextStyles.bodySmall),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildSignDropdown(
                'Tu Signo',
                _signo1,
                (val) => setState(() {
                  _signo1 = val;
                  _resultadoCompatibilidad = null;
                }),
                locked: _isSignLocked,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            Expanded(
              child: _buildSignDropdown(
                'Comparar',
                _signo2,
                (val) => setState(() {
                  _signo2 = val;
                  _resultadoCompatibilidad = null;
                }),
                locked: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        GlowButton(
          onPressed: _calcularCompatibilidad,
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 17),
              const SizedBox(width: 10),
              Text(
                'Calcular Afinidad',
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        if (_resultadoCompatibilidad != null) ...[
          const SizedBox(height: 36),
          _buildCompatibilidadResult(),
        ],
      ],
    );
  }

  Widget _buildCompatibilidadResult() {
    final result = _resultadoCompatibilidad!;
    final global = result['global'] as int;

    return Column(
      children: [
        // Círculo porcentaje global
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2D1B69), Color(0xFF0F0D1A)],
              ),
              border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$global%',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('AFINIDAD', style: AppTextStyles.labelGold),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Barras de progreso
        _buildProgressRow(
          '💖  Amor',
          result['amor'] as int,
          AppGradients.loveBar,
        ),
        _buildProgressRow(
          '🤝  Amistad',
          result['amistad'] as int,
          AppGradients.friendshipBar,
        ),
        _buildProgressRow(
          '💼  Trabajo',
          result['trabajo'] as int,
          AppGradients.workBar,
        ),
        const SizedBox(height: 20),

        // Descripción
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1040), Color(0xFF0F0D1A)],
            ),
            border: Border.all(color: AppColors.borderGold),
          ),
          child: Text(
            result['descripcion'] as String,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, int value, Gradient barGradient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
              Text(
                '$value%',
                style: GoogleFonts.cinzel(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                    height: 8,
                    color: AppColors.bgElevated),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: barGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged, {
    required bool locked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderPrimary),
            color: AppColors.bgSurface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppColors.bgElevated,
              value: value,
              hint: Text(
                'Elegir',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 13),
              ),
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppColors.primaryLight, size: 20),
              isExpanded: true,
              onChanged: locked ? null : onChanged,
              items: _signos.map<DropdownMenuItem<String>>((signo) {
                return DropdownMenuItem<String>(
                  value: signo['nombre'] as String,
                  child: Row(
                    children: [
                      Text(signo['icono'] as String,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(signo['nombre'] as String),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ZODIAC CARD
// ─────────────────────────────────────────────
class _ZodiacCard extends StatelessWidget {
  final Map<String, dynamic> signo;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ZodiacCard({
    required this.signo,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D1B69), Color(0xFF1A1630)],
                )
              : null,
          color: isSelected ? null : AppColors.bgSurface,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight.withOpacity(0.7)
                : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              signo['icono'] as String,
              style: TextStyle(
                fontSize: 28,
                color: isSelected ? null : const Color(0xFFD0C8FF),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              signo['nombre'] as String,
              style: GoogleFonts.cinzel(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              signo['fechas'] as String,
              style: GoogleFonts.inter(
                color: AppColors.textMuted.withOpacity(0.6),
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
