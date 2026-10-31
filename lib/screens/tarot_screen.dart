import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/tarot_card_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../widgets/paywall_modal.dart';
import '../widgets/mystic_loader.dart';
import '../widgets/card_detail_dialog.dart';

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
  final Set<int> _flippedIndices = {};
  StreamSubscription<List<TarotCardModel>>? _tarotSubscription;

  final List<Map<String, dynamic>> _tiposLectura = [
    {
      'valor': 'pasado',
      'titulo': 'Pasado',
      'descripcion': 'Descubre eventos que te han marcado',
      'icon': Icons.history_edu_rounded,
      'color': AppColors.primary,
      'cartas': 1,
    },
    {
      'valor': 'presente',
      'titulo': 'Presente',
      'descripcion': 'Comprende tu situación actual',
      'icon': Icons.visibility_rounded,
      'color': AppColors.primaryLight,
      'cartas': 1,
    },
    {
      'valor': 'posible futuro',
      'titulo': 'Posible Futuro',
      'descripcion': 'Vislumbra lo que puede venir (3 cartas)',
      'icon': Icons.explore_rounded,
      'color': AppColors.gold,
      'cartas': 3,
    },
    {
      'valor': 'pregunta directa',
      'titulo': 'Pregunta',
      'descripcion': 'Obtén respuesta a tu pregunta',
      'icon': Icons.quiz_rounded,
      'color': AppColors.teal,
      'cartas': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarCartas();
  }

  @override
  void dispose() {
    _tarotSubscription?.cancel();
    _preguntaController.dispose();
    super.dispose();
  }

  void _cargarCartas() {
    // Si ya existen cartas en caché de memoria, mostrarlas instantáneamente con 0 espera
    final cached = DatabaseService().cachedTarotCards;
    if (cached != null && cached.isNotEmpty) {
      _todasLasCartas = cached;
      _cargando = false;
    }

    _tarotSubscription = DatabaseService().streamTarotCards().listen(
      (cartas) {
        if (mounted) {
          setState(() {
            _todasLasCartas = cartas.isEmpty ? _generarCartasLocalesDeRespaldo() : cartas;
            _cargando = false;
          });
        }
      },
      onError: (error) {
        debugPrint("Error cargando cartas de tarot: $error");
        if (mounted) {
          setState(() {
            _todasLasCartas = _generarCartasLocalesDeRespaldo();
            _cargando = false;
          });
        }
      },
    );
  }

  List<TarotCardModel> _generarCartasLocalesDeRespaldo() {
    return [
      TarotCardModel(
        id: 'carta_0',
        nombre: 'El Loco',
        significado: 'Nuevos comienzos, espontaneidad, fe en el camino y libertad de espíritu.',
        descripcionExtendida: 'Representa dar un salto de fe hacia lo desconocido. Confía en el universo y abre tu mente a nuevas aventuras.',
        orden: 0,
      ),
      TarotCardModel(
        id: 'carta_1',
        nombre: 'El Mago',
        significado: 'Poder personal, iniciativa, concentración y la manifestación de tus deseos.',
        descripcionExtendida: 'Simboliza que tienes todas las herramientas y recursos necesarios a tu disposición para lograr lo que te propones.',
        orden: 1,
      ),
      TarotCardModel(
        id: 'carta_2',
        nombre: 'La Sacerdotisa',
        significado: 'Intuición, misterio, sabiduría interior y el plano espiritual.',
        descripcionExtendida: 'Es momento de escuchar tu voz interna y confiar en tus presentimientos. No busques respuestas en el exterior.',
        orden: 2,
      ),
      TarotCardModel(
        id: 'carta_3',
        nombre: 'La Emperatriz',
        significado: 'Abundancia, creatividad, fertilidad, naturaleza y plenitud.',
        descripcionExtendida: 'Representa la creación y el florecimiento. Conéctate con tus sentidos y permite que tus ideas cobren vida.',
        orden: 3,
      ),
      TarotCardModel(
        id: 'carta_4',
        nombre: 'El Sacerdote',
        significado: 'Sabiduría tradicional, enseñanza, guía espiritual y valores establecidos.',
        descripcionExtendida: 'Sugiere buscar el consejo de mentores o seguir un camino estructurado de aprendizaje.',
        orden: 4,
      ),
      TarotCardModel(
        id: 'carta_5',
        nombre: 'El Amor',
        significado: 'Elecciones importantes, amor, alineación de valores y relaciones.',
        descripcionExtendida: 'Habla de tomar decisiones desde el corazón y encontrar la armonía contigo mismo y los demás.',
        orden: 5,
      ),
      TarotCardModel(
        id: 'carta_6',
        nombre: 'El Ermitaño',
        significado: 'Introspección, soledad buscada, reflexión y autodescubrimiento.',
        descripcionExtendida: 'Invita a retirarse del ruido del mundo exterior para encontrar la luz y las respuestas dentro de uno mismo.',
        orden: 6,
      ),
      TarotCardModel(
        id: 'carta_7',
        nombre: 'La Rueda de la Fortuna',
        significado: 'Cambio, ciclos, destino y puntos de inflexión inesperados.',
        descripcionExtendida: 'Nos recuerda que la vida está llena de altibajos y ciclos. Acepta los cambios con gracia y adaptabilidad.',
        orden: 7,
      ),
      TarotCardModel(
        id: 'carta_8',
        nombre: 'La Fuerza',
        significado: 'Coraje, paciencia, compasión y control sobre los impulsos.',
        descripcionExtendida: 'Nos recuerda que el verdadero poder reside en la suavidad y el control interno, no en la fuerza física.',
        orden: 8,
      ),
      TarotCardModel(
        id: 'carta_9',
        nombre: 'La Muerte',
        significado: 'Finales necesarios, transformación profunda, transición y liberación.',
        descripcionExtendida: 'No representa la muerte física, sino el cierre de un ciclo para dar paso a un nuevo comienzo renovado.',
        orden: 9,
      ),
      TarotCardModel(
        id: 'carta_10',
        nombre: 'La Torre',
        significado: 'Cambio repentino, revelación, despertar espiritual y liberación de ilusiones.',
        descripcionExtendida: 'Simboliza la destrucción de estructuras obsoletas para construir sobre bases más sólidas y verdaderas.',
        orden: 10,
      ),
      TarotCardModel(
        id: 'carta_11',
        nombre: 'El Mundo',
        significado: 'Completitud, logro supremo, viaje completado e integración.',
        descripcionExtendida: 'Celebra el éxito, la realización de un proyecto y la armonía con el universo.',
        orden: 11,
      ),
      TarotCardModel(
        id: 'carta_12',
        nombre: 'El Bufón',
        significado: 'Diversión, ingenio, ironía y ver la vida desde otra perspectiva.',
        descripcionExtendida: 'Representa el humor y la ligereza ante las dificultades. No te tomes las cosas tan en serio.',
        orden: 12,
      ),
      TarotCardModel(
        id: 'carta_13',
        nombre: 'El Camino',
        significado: 'Dirección, elecciones de vida, sendero evolutivo y destino.',
        descripcionExtendida: 'Simboliza el trayecto que recorres. Cada paso cuenta y te acerca más a tu verdadero propósito.',
        orden: 13,
      ),
      TarotCardModel(
        id: 'carta_14',
        nombre: 'El Duende',
        significado: 'Travesura, suerte inesperada, conexión con la naturaleza y magia elemental.',
        descripcionExtendida: 'Representa la astucia y los pequeños regalos de la vida. Mantente alerta a las sincronicidades.',
        orden: 14,
      ),
      TarotCardModel(
        id: 'carta_15',
        nombre: 'El Miedo',
        significado: 'Bloqueos mentales, temores inconscientes y la necesidad de superarse.',
        descripcionExtendida: 'Enfréntate a tus sombras. El miedo es solo una ilusión que bloquea tu potencial.',
        orden: 15,
      ),
      TarotCardModel(
        id: 'carta_16',
        nombre: 'El Perdón',
        significado: 'Liberación de resentimientos, paz interior y sanación emocional.',
        descripcionExtendida: 'Perdonar no es justificar al otro, sino liberarte a ti mismo del peso del pasado.',
        orden: 16,
      ),
      TarotCardModel(
        id: 'carta_17',
        nombre: 'El Rey',
        significado: 'Liderazgo, control, estabilidad, sabiduría y protección.',
        descripcionExtendida: 'Representa la madurez y la capacidad de tomar decisiones firmes con justicia y benevolencia.',
        orden: 17,
      ),
      TarotCardModel(
        id: 'carta_18',
        nombre: 'El Viaje',
        significado: 'Movimiento, exploración, cambio de perspectiva y crecimiento personal.',
        descripcionExtendida: 'Simboliza un traslado físico o un viaje interior hacia nuevas comprensiones.',
        orden: 18,
      ),
      TarotCardModel(
        id: 'carta_19',
        nombre: 'Gran Premio',
        significado: 'Recompensa merecida, abundancia, éxito rotundo y fortuna.',
        descripcionExtendida: 'El universo premia tu esfuerzo. Disfruta de la cosecha y sé agradecido.',
        orden: 19,
      ),
      TarotCardModel(
        id: 'carta_20',
        nombre: 'La Bruja',
        significado: 'Magia práctica, intuición profunda, conexión con lo sagrado femenino y sabiduría.',
        descripcionExtendida: 'Representa el poder de manifestar mediante el conocimiento de los ciclos y elementos.',
        orden: 20,
      ),
      TarotCardModel(
        id: 'carta_21',
        nombre: 'La Envidia',
        significado: 'Celos, energías discordantes externas o internas, y la necesidad de autovaloración.',
        descripcionExtendida: 'Protege tu energía y enfócate en tu propio camino. No compares tu proceso con el de otros.',
        orden: 21,
      ),
      TarotCardModel(
        id: 'carta_22',
        nombre: 'La Ira',
        significado: 'Pasión desbordada, enojo acumulado y necesidad de transmutación.',
        descripcionExtendida: 'Usa esa fuerza motora de manera constructiva. No dejes que el impulso destruya lo que has construido.',
        orden: 22,
      ),
      TarotCardModel(
        id: 'carta_23',
        nombre: 'La Pobreza',
        significado: 'Mentalidad de escasez, dificultades temporales y necesidad de apoyo.',
        descripcionExtendida: 'Recuerda que la verdadera abundancia comienza en la mente. Busca ayuda y confía en el cambio.',
        orden: 23,
      ),
      TarotCardModel(
        id: 'carta_24',
        nombre: 'La Reina',
        significado: 'Poder receptivo, intuición, empatía, madurez emocional y soberanía.',
        descripcionExtendida: 'Simboliza reinar sobre tus propias emociones y sostener un espacio seguro para otros.',
        orden: 24,
      ),
      TarotCardModel(
        id: 'carta_25',
        nombre: 'La Traición',
        significado: 'Decepción, deslealtad, cortes dolorosos y aprendizaje de la confianza.',
        descripcionExtendida: 'Aunque dolorosa, revela la verdad. Te permite ver las intenciones reales y liberarte de ilusiones.',
        orden: 25,
      ),
      TarotCardModel(
        id: 'carta_26',
        nombre: 'Negocios',
        significado: 'Acuerdos comerciales, transacciones, alianzas de trabajo y éxito financiero.',
        descripcionExtendida: 'Momento ideal para negociar, firmar contratos y establecer planes financieros claros.',
        orden: 26,
      ),
      TarotCardModel(
        id: 'carta_27',
        nombre: 'Oro',
        significado: 'Riqueza material, valor intrínseco, éxito sólido y prosperidad.',
        descripcionExtendida: 'Representa la solidez económica y los logros materiales. Mantén tus valores firmes.',
        orden: 27,
      ),
      TarotCardModel(
        id: 'carta_28',
        nombre: 'Plata',
        significado: 'Claridad mental, intuición, valor emocional y adaptabilidad.',
        descripcionExtendida: 'Conexión con la energía lunar. Buen momento para la reflexión y el flujo receptivo.',
        orden: 28,
      ),
      TarotCardModel(
        id: 'carta_29',
        nombre: 'Reconciliación',
        significado: 'Unión de opuestos, sanación de relaciones, paz y armonía recobrada.',
        descripcionExtendida: 'El entendimiento mutuo regresa. Abre tu corazón al diálogo y al entendimiento.',
        orden: 29,
      ),
      TarotCardModel(
        id: 'carta_30',
        nombre: 'Salud',
        significado: 'Bienestar físico, mental y espiritual, vitalidad y equilibrio orgánico.',
        descripcionExtendida: 'Cuida tu cuerpo y tu mente. Representa una recuperación energética o estabilidad de salud.',
        orden: 30,
      ),
      TarotCardModel(
        id: 'carta_31',
        nombre: 'Sorpresa',
        significado: 'Eventos inesperados, regalos del destino y giros del destino.',
        descripcionExtendida: 'Mantén la mente abierta. Lo inesperado trae nuevas oportunidades y aprendizajes.',
        orden: 31,
      ),
      TarotCardModel(
        id: 'carta_32',
        nombre: 'Suerte',
        significado: 'Buena fortuna, sincronicidades favorables y viento a favor.',
        descripcionExtendida: 'El azar te favorece en este momento. Aprovecha las oportunidades que se presenten.',
        orden: 32,
      ),
      TarotCardModel(
        id: 'carta_33',
        nombre: 'Trabajo',
        significado: 'Esfuerzo constante, dedicación, desarrollo profesional y labor diaria.',
        descripcionExtendida: 'La constancia rinde frutos. Dedica tiempo a perfeccionar tus habilidades y proyectos.',
        orden: 33,
      ),
      TarotCardModel(
        id: 'carta_34',
        nombre: 'Ángel',
        significado: 'Protección divina, guía celestial, pureza y mensajes de paz.',
        descripcionExtendida: 'No estás solo. Estás siendo protegido y guiado por fuerzas de luz del plano superior.',
        orden: 34,
      ),
      TarotCardModel(
        id: 'carta_35',
        nombre: 'Carta Negra',
        significado: 'Energías densas, advertencia, autoanálisis profundo y cautela.',
        descripcionExtendida: 'Momento de limpiar tus espacios y pensamientos. Protégete de influencias negativas externas.',
        orden: 35,
      ),
      TarotCardModel(
        id: 'carta_36',
        nombre: 'Carta Blanca',
        significado: 'Posibilidades infinitas, destino libre y poder de elección total.',
        descripcionExtendida: 'Tienes la libertad de escribir tu propia historia sin ataduras. El lienzo está en blanco.',
        orden: 36,
      ),
      TarotCardModel(
        id: 'carta_37',
        nombre: 'Dinero',
        significado: 'Flujo financiero, ingresos, transacciones económicas y seguridad material.',
        descripcionExtendida: 'Simboliza la entrada de recursos económicos o la necesidad de administrarlos con prudencia.',
        orden: 37,
      ),
    ];
  }

  Future<void> _realizarLectura() async {
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

    final user = Provider.of<AuthService>(context, listen: false).userModel;
    final tipo = _tiposLectura.firstWhere((t) => t['valor'] == _tipoLectura);
    final int cartasNecesarias = tipo['cartas'] as int;

    // Verificar si el usuario gratuito tiene cartas disponibles
    if (user != null && !user.isMembershipActive) {
      final disponibles = user.freeTarotCardsAvailable;
      if (disponibles < cartasNecesarias) {
        PaywallModal.show(
          context,
          title: 'Cartas Agotadas',
          description: disponibles == 0
              ? 'Ya usaste tus 2 cartas de tarot gratuitas este mes. Activa tu membresía premium para consultas ilimitadas.'
              : 'Esta lectura requiere $cartasNecesarias carta(s) pero solo te queda $disponibles. Activa tu membresía para acceso ilimitado.',
        );
        return;
      }
    }

    final random = Random();
    final cartasBarajadas = List<TarotCardModel>.from(_todasLasCartas)
      ..shuffle(random);

    int numCartas = cartasNecesarias;

    setState(() {
      _cartasSeleccionadas = cartasBarajadas.take(numCartas).toList();
      _flippedIndices.clear();
    });

    // Registrar uso en Firestore para usuarios gratuitos
    if (user != null && !user.isMembershipActive) {
      await DatabaseService().markFreeTarotCardsUsed(user.uid, numCartas);
      if (mounted) {
        await Provider.of<AuthService>(context, listen: false).reloadCurrentUser();
      }
    }
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
    return const Center(
      child: MysticLoader(text: 'Consultando el oráculo...'),
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
    final user = Provider.of<AuthService>(context).userModel;
    final isPremium = user?.isMembershipActive ?? false;
    final cartasDisponibles = user?.freeTarotCardsAvailable ?? 2;

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

          // Indicador de cartas disponibles para plan gratis
          if (!isPremium) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cartasDisponibles > 0
                    ? AppColors.gold.withOpacity(0.08)
                    : AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cartasDisponibles > 0
                      ? AppColors.gold.withOpacity(0.35)
                      : AppColors.primary.withOpacity(0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cartasDisponibles > 0
                        ? Icons.auto_awesome
                        : Icons.lock_outline_rounded,
                    color: cartasDisponibles > 0 ? AppColors.gold : AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cartasDisponibles > 0
                          ? 'Te quedan $cartasDisponibles carta(s) gratuita(s) este mes'
                          : 'Has usado tus 2 cartas gratuitas de este mes',
                      style: GoogleFonts.inter(
                        color: cartasDisponibles > 0 ? AppColors.gold : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ── Grid de tipos de lectura ────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.20,
            ),
            itemCount: _tiposLectura.length,
            itemBuilder: (context, index) {
              final tipo = _tiposLectura[index];
              final isSelected = _tipoLectura == tipo['valor'];
              final int cartasNecesarias = tipo['cartas'] as int;
              // Bloqueada si no es premium y no tiene suficientes cartas
              final isLocked = !isPremium && cartasDisponibles < cartasNecesarias;
              return _ReadingTypeCard(
                tipo: tipo,
                isSelected: isSelected,
                isLocked: isLocked,
                onTap: () {
                  if (isLocked) {
                    PaywallModal.show(
                      context,
                      title: 'Cartas Agotadas',
                      description: cartasDisponibles == 0
                          ? 'Ya usaste tus 2 cartas de tarot gratuitas este mes. Activa tu membresía premium para acceso ilimitado.'
                          : 'Esta lectura requiere $cartasNecesarias carta(s) pero solo te queda $cartasDisponibles. Activa tu membresía para acceso ilimitado.',
                    );
                  } else {
                    setState(() {
                      _tipoLectura = tipo['valor'] as String;
                      _cartasSeleccionadas = [];
                    });
                  }
                },
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: _TarotCardFlipWidget(
                    key: ValueKey('${carta.id}_$index'),
                    carta: carta,
                    posicion: posicion,
                    onFlip: () {
                      setState(() {
                        _flippedIndices.add(index);
                      });
                    },
                  ),
                ),
              );
            }),
            if (_flippedIndices.length == _cartasSeleccionadas.length) ...[
              const SizedBox(height: 20),
              GlowButton(
                onPressed: () => _mostrarInterpretacionIA(context),
                height: 56,
                glowColor: AppColors.gold,
                gradient: AppGradients.goldButton,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Interpretar Tirada',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'El Maestro interpretará el misterio de tu destino.',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
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

  void _mostrarInterpretacionIA(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Interpretación IA',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _AIInterpretationDialog(
          pregunta: _preguntaController.text,
          tipoLectura: _tipoLectura ?? '',
          cartas: _cartasSeleccionadas,
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        );
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
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
  final bool isLocked;
  final VoidCallback onTap;

  const _ReadingTypeCard({
    required this.tipo,
    required this.isSelected,
    required this.isLocked,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
          child: Stack(
            children: [
              Column(
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
              if (isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: AppColors.gold,
                      size: 14,
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
// TAROT CARD FLIP WIDGET
// ─────────────────────────────────────────────
class _TarotCardFlipWidget extends StatefulWidget {
  final TarotCardModel carta;
  final String posicion;
  final VoidCallback onFlip;

  const _TarotCardFlipWidget({
    required this.carta,
    required this.posicion,
    required this.onFlip,
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
      widget.onFlip();
    } else {
      CardDetailDialog.show(
        context,
        nombre: widget.carta.nombre,
        significado: widget.carta.significado,
        orden: widget.carta.orden,
        imageUrl: widget.carta.imageUrl,
        subtitle: widget.posicion.isNotEmpty ? widget.posicion : null,
      );
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
        if (_isFlipped) ...[
          const SizedBox(height: 12),
          Text(
            widget.carta.nombre.toUpperCase(),
            style: GoogleFonts.cinzel(
              color: AppColors.gold,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBackSide() {
    return Container(
      width: 150,
      height: 280,
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
              padding: const EdgeInsets.all(8.0),
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
              top: 10,
              left: 10,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              bottom: 10,
              left: 10,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          Positioned(
              bottom: 10,
              right: 10,
              child: Icon(Icons.star_rounded,
                  size: 8, color: AppColors.gold.withOpacity(0.4))),
          // Centro
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
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
                    color: AppColors.gold, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'REVELAR',
                style: GoogleFonts.cinzel(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSprite(TarotCardModel carta) {
    final double displayWidth = 150.0;
    final double displayHeight = 280.0;
    
    return Container(
      width: displayWidth,
      height: displayHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.32),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: carta.imageUrl != null && carta.imageUrl!.isNotEmpty
            ? Image.network(
                carta.imageUrl!,
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/tarot/carta_${carta.orden}.png',
                  width: displayWidth,
                  height: displayHeight,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/images/tarot/carta_${carta.orden}.png',
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildFrontSide() {
    return _buildCardSprite(widget.carta);
  }
}

// ─────────────────────────────────────────────
// DIALOGO DE INTERPRETACION DE IA
// ─────────────────────────────────────────────
class _AIInterpretationDialog extends StatefulWidget {
  final String pregunta;
  final String tipoLectura;
  final List<TarotCardModel> cartas;

  const _AIInterpretationDialog({
    required this.pregunta,
    required this.tipoLectura,
    required this.cartas,
  });

  @override
  State<_AIInterpretationDialog> createState() => _AIInterpretationDialogState();
}

class _AIInterpretationDialogState extends State<_AIInterpretationDialog> {
  bool _cargando = true;
  String? _error;
  String? _resultado;

  @override
  void initState() {
    super.initState();
    _ejecutarConsulta();
  }

  Future<void> _ejecutarConsulta() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final user = Provider.of<AuthService>(context, listen: false).userModel;
      final interpretacion = await GeminiService().obtenerInterpretacion(
        pregunta: widget.pregunta.trim().isEmpty ? "Consulta general sin pregunta específica" : widget.pregunta,
        tipoLectura: widget.tipoLectura,
        cartas: widget.cartas,
        nombreConsultante: user?.name,
        signoZodiacal: user?.zodiacSign,
        fechaNacimiento: user?.birthDate,
      );
      if (mounted) {
        setState(() {
          _resultado = interpretacion;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E0000), Color(0xFF111111), Color(0xFF0C0C0C)],
          ),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ORÁCULO MÍSTICO',
                      style: GoogleFonts.cinzel(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                if (!_cargando)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.gold, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.borderGold.withOpacity(0.2)),
            const SizedBox(height: 16),
            Flexible(
              child: _buildContenido(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: MysticLoader(
          text: 'Las fuerzas del oráculo interpretan tu destino...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.primaryLight, size: 40),
              const SizedBox(height: 16),
              Text(
                'El oráculo no puede revelarte tu destino en este momento.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Las energías espirituales están saturadas o la conexión con el plano astral se ha interrumpido.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _ejecutarConsulta,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('REINTENTAR CONSULTA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.pregunta.trim().isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREGUNTA:',
                      style: GoogleFonts.cinzel(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${widget.pregunta}"',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              _resultado ?? '',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


