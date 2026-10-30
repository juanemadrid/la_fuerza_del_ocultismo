import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mystic_loader.dart';
import '../services/audio_service.dart';

class ChatMaestroScreen extends StatefulWidget {
  const ChatMaestroScreen({super.key});

  @override
  State<ChatMaestroScreen> createState() => _ChatMaestroScreenState();
}

class _ChatMaestroScreenState extends State<ChatMaestroScreen>
    with WidgetsBindingObserver {
  final List<Map<String, String>> _mensajes = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _cargando = false;
  bool _audioEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Mensaje de bienvenida personalizado automático
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<AuthService>(context, listen: false).userModel;
      if (user != null) {
        String saludo = 'Bendiciones, ${user.name}.';
        if (user.zodiacSign.isNotEmpty) {
          saludo +=
              ' Siento que la vibración de tu signo ${user.zodiacSign} está inquieta en este ciclo.';
        }
        saludo +=
            ' Soy el asistente virtual del Maestro. Podemos explorar el tarot y la astrología como herramientas de reflexión. Si te apetece, respira con calma antes de comenzar.\n\n¿Qué te gustaría explorar hoy?';

        setState(() {
          _mensajes.add({
            'role': 'model',
            'text': saludo,
          });
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SpiritualAudioManager().detenerAmbiente();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      SpiritualAudioManager().pausarAmbiente();
    } else if (state == AppLifecycleState.resumed) {
      SpiritualAudioManager().reanudarAmbiente();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user == null) return;

    _controller.clear();
    setState(() {
      _mensajes.add({
        'role': 'user',
        'text': texto,
      });
      _cargando = true;
    });
    _scrollToBottom();

    try {
      final respuesta = await GeminiService().obtenerRespuestaChat(
        historial: _mensajes,
        nombreConsultante: user.name,
        signoZodiacal: user.zodiacSign,
        fechaNacimiento: user.birthDate,
      );

      if (mounted) {
        setState(() {
          _mensajes.add({
            'role': 'model',
            'text': respuesta,
          });
          _cargando = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensajes.add({
            'role': 'model',
            'text':
                'No pudimos obtener una respuesta. Revisa tu conexión e inténtalo de nuevo en un momento.',
          });
          _cargando = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundRadial,
        ),
        child: Column(
          children: [
            Expanded(
              child: _mensajes.isEmpty
                  ? const Center(
                      child: MysticLoader(text: 'Sintonizando plano astral...'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      itemCount: _mensajes.length + (_cargando ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _mensajes.length) {
                          return _buildLoaderBubble();
                        }
                        return _buildMessageBubble(_mensajes[index]);
                      },
                    ),
            ),
            _buildInputSection(),
          ],
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
            color: AppColors.gold, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: _audioEnabled
              ? 'Desactivar sonido ambiental'
              : 'Activar sonido ambiental',
          icon: Icon(
              _audioEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: AppColors.gold),
          onPressed: () {
            setState(() => _audioEnabled = !_audioEnabled);
            if (_audioEnabled) {
              SpiritualAudioManager().iniciarAmbiente();
            } else {
              SpiritualAudioManager().detenerAmbiente();
            }
          },
        )
      ],
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EL MAESTRO',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Asistente virtual · IA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white54,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderGold.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> mensaje) {
    final isModel = mensaje['role'] == 'model';

    // Avatar del Maestro
    final modelAvatar = Container(
      margin: const EdgeInsets.only(right: 8, bottom: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: const Icon(Icons.auto_awesome_rounded,
          color: AppColors.gold, size: 12),
    );

    // Avatar del Usuario
    final userAvatar = Container(
      margin: const EdgeInsets.only(left: 8, bottom: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.bgBase],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 12),
    );

    return Row(
      mainAxisAlignment:
          isModel ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isModel) modelAvatar,
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isModel ? 4 : 16),
                bottomRight: Radius.circular(isModel ? 16 : 4),
              ),
              border: Border.all(
                color: isModel
                    ? AppColors.gold.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.4),
              ),
              gradient: LinearGradient(
                colors: isModel
                    ? [AppColors.bgSurface, const Color(0xFF140D0D)]
                    : [
                        AppColors.primary.withValues(alpha: 0.35),
                        AppColors.bgBase
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              mensaje['text'] ?? '',
              style: TextStyle(
                fontFamily: 'Inter',
                color: isModel ? AppColors.gold : Colors.white,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ),
        if (!isModel) userAvatar,
      ],
    );
  }

  Widget _buildLoaderBubble() {
    final modelAvatar = Container(
      margin: const EdgeInsets.only(right: 8, bottom: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: const Icon(Icons.auto_awesome_rounded,
          color: AppColors.gold, size: 12),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        modelAvatar,
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            color: AppColors.bgSurface.withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'El Maestro canaliza energías...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.gold.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        border: Border(
          top: BorderSide(
            color: AppColors.borderGold.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                  fontFamily: 'Inter', color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Formula tu pregunta al Maestro...',
                hintStyle: const TextStyle(
                    fontFamily: 'Inter', color: Colors.white30, fontSize: 13),
                filled: true,
                fillColor: AppColors.bgSurface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _enviarMensaje,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.gold, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
