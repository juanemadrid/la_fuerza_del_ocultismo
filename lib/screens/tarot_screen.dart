import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/tarot_card_model.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  String? _tipoLectura;
  List<TarotCardModel> _cartasSeleccionadas = [];
  final TextEditingController _preguntaController = TextEditingController();
  List<TarotCardModel> _todasLasCartas = [];
  bool _cargando = true;

  final List<Map<String, dynamic>> _tiposLectura = [
    {
      'valor': 'pasado',
      'titulo': 'Pasado',
      'descripcion': 'Descubre eventos que te han marcado',
      'icon': Icons.history_edu_rounded,
      'color': AppColors.primary,
    },
    {
      'valor': 'presente',
      'titulo': 'Presente',
      'descripcion': 'Comprende tu situación actual',
      'icon': Icons.visibility_rounded,
      'color': AppColors.primaryLight,
    },
    {
      'valor': 'posible futuro',
      'titulo': 'Posible Futuro',
      'descripcion': 'Vislumbra lo que puede venir (3 cartas)',
      'icon': Icons.explore_rounded,
      'color': AppColors.gold,
    },
    {
      'valor': 'pregunta directa',
      'titulo': 'Pregunta',
      'descripcion': 'Obtén respuesta a tu pregunta',
      'icon': Icons.quiz_rounded,
      'color': AppColors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarCartas();
  }

  void _cargarCartas() {
    DatabaseService().streamTarotCards().listen((cartas) {
      if (mounted) {
        setState(() {
          _todasLasCartas = cartas;
          _cargando = false;
        });
      }
    });
  }

  void _realizarLectura() {
    if (_tipoLectura == null || _todasLasCartas.isEmpty) return;

    if (_tipoLectura == 'pregunta directa' &&
        _preguntaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor escribe tu pregunta',
            style: GoogleFonts.inter(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final random = Random();
    final cartasBarajadas = List<TarotCardModel>.from(_todasLasCartas)
      ..shuffle(random);

    int numCartas = 1;
    if (_tipoLectura == 'posible futuro') numCartas = 3;

    setState(() {
      _cartasSeleccionadas = cartasBarajadas.take(numCartas).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: _buildAppBar(),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppGradients.backgroundRadial),
        child: _cargando
            ? _buildLoading()
            : _todasLasCartas.isEmpty
                ? _buildEmpty()
                : _buildContent(),
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
          'TAROT',
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
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.borderGold,
                Colors.transparent
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            'Consultando el oráculo...',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome,
                color: AppColors.textMuted.withOpacity(0.4), size: 56),
            const SizedBox(height: 20),
            Text(
              'El mazo de tarot aún no está configurado.\nConsulta con el maestro.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textMuted, fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título sección ──────────────────────────────
          Text('Tipo de Lectura', style: AppTextStyles.titleLarge),
          const SizedBox(height: 6),
          Text('Elige cómo el tarot te hablará hoy',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),

          // ── Grid de tipos de lectura ────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: _tiposLectura.length,
            itemBuilder: (context, index) {
              final tipo = _tiposLectura[index];
              final isSelected = _tipoLectura == tipo['valor'];
              return _ReadingTypeCard(
                tipo: tipo,
                isSelected: isSelected,
                onTap: () => setState(() {
                  _tipoLectura = tipo['valor'] as String;
                  _cartasSeleccionadas = [];
                }),
              );
            },
          ),

          // ── Campo pregunta directa ──────────────────────
          if (_tipoLectura == 'pregunta directa') ...[
            const SizedBox(height: 28),
            Text('Tu Pregunta', style: AppTextStyles.titleMedium),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 1),
                color: AppColors.bgSurface,
              ),
              child: TextField(
                controller: _preguntaController,
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta aquí...',
                  hintStyle:
                      GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],

          // ── Botón consultar ─────────────────────────────
          if (_tipoLectura != null) ...[
            const SizedBox(height: 30),
            GlowButton(
              onPressed: _realizarLectura,
              height: 58,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Consultar las Cartas',
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
          ],

          // ── Resultado: cartas ───────────────────────────
          if (_cartasSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: 44),
            _buildLecturaTitle(),
            const SizedBox(height: 26),
            ..._cartasSeleccionadas.asMap().entries.map((entry) {
              final index = entry.key;
              final carta = entry.value;
              String posicion = '';
              if (_tipoLectura == 'posible futuro') {
                if (index == 0) posicion = 'Pasado';
                else if (index == 1) posicion = 'Presente';
                else posicion = 'Posible Futuro';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: _TarotCardFlipWidget(
                  key: ValueKey('${carta.id}_$index'),
                  carta: carta,
                  posicion: posicion,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLecturaTitle() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.borderGold],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tu Lectura',
            style: GoogleFonts.cinzel(
              color: AppColors.gold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.borderGold, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
// READING TYPE CARD
// ─────────────────────────────────────────────
class _ReadingTypeCard extends StatelessWidget {
  final Map<String, dynamic> tipo;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReadingTypeCard({
    required this.tipo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tipo['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.22),
                      color.withOpacity(0.07),
                    ],
                  )
                : const LinearGradient(
                    colors: [AppColors.bgSurface, AppColors.bgSurface]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.7) : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 14,
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.18)
                      : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  tipo['icon'] as IconData,
                  color: isSelected ? color : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tipo['titulo'] as String,
                style: GoogleFonts.cinzel(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tipo['descripcion'] as String,
                style: GoogleFonts.inter(
                  color: isSelected
                      ? AppColors.textSecondary
                      : AppColors.textMuted.withOpacity(0.55),
                  fontSize: 10,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAROT CARD FLIP WIDGET
// ─────────────────────────────────────────────
class _TarotCardFlipWidget extends StatefulWidget {
  final TarotCardModel carta;
  final String posicion;

  const _TarotCardFlipWidget({
    required this.carta,
    required this.posicion,
    super.key,
  });

  @override
  State<_TarotCardFlipWidget> createState() => _TarotCardFlipWidgetState();
}

class _TarotCardFlipWidgetState extends State<_TarotCardFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isFlipped) {
      _controller.forward();
      setState(() => _isFlipped = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.posicion.isNotEmpty) ...[
          Text(
            widget.posicion.toUpperCase(),
            style: AppTextStyles.labelGold,
          ),
          const SizedBox(height: 10),
        ],
        GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * pi;
              final isFront = angle >= pi / 2;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: isFront
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildFrontSide(),
                      )
                    : _buildBackSide(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0000), Color(0xFF0D0000), Color(0xFF080808)],
        ),
        border:
            Border.all(color: AppColors.gold.withOpacity(0.38), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 26,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Marco interior
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.12), width: 1),
                ),
              ),
            ),
          ),
          // Estrellas de esquina
          Positioned(
              top: 16,
              left: 16,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              top: 16,
              right: 16,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              bottom: 16,
              left: 16,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              bottom: 16,
              right: 16,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          // Centro
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.28),
                      AppColors.primary.withOpacity(0.04),
                    ],
                  ),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.38), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.38),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.gold, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                'REVELAR CARTA',
                style: GoogleFonts.cinzel(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0000), Color(0xFF111111)],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.32),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícono con gradiente dorado
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) => const LinearGradient(
              colors: [AppColors.gold, AppColors.primaryLight],
            ).createShader(b),
            child: const Icon(Icons.auto_awesome, size: 38),
          ),
          const SizedBox(height: 14),
          // Línea divisoria dorada
          Container(
            width: 50,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.gold, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.carta.nombre.toUpperCase(),
            style: GoogleFonts.cinzel(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            widget.carta.significado,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.carta.descripcionExtendida.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 16),
            Text(
              widget.carta.descripcionExtendida,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
