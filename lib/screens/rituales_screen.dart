import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/content_file_model.dart';
import 'pdf_viewer_screen.dart';


// Datos de muestra para mostrar cuando Firestore está vacío
const _ritualesMuestra = [
  {
    'title': 'Ritual de Limpieza Energética Profunda',
    'description': 'Elimina bloqueos y energías negativas acumuladas. Ideal para iniciar un nuevo ciclo con claridad y fuerza.',
    'locked': false,
  },
  {
    'title': 'Ritual para Atraer Abundancia',
    'description': 'Abre los canales de prosperidad y abundancia económica usando las fuerzas del universo.',
    'locked': true,
  },
  {
    'title': 'Ritual de Protección Personal',
    'description': 'Crea un escudo espiritual que te protege de envidias, malas energías y ataques psíquicos.',
    'locked': true,
  },
  {
    'title': 'Ritual para el Amor y los Vínculos',
    'description': 'Fortalece los lazos afectivos, atrae el amor verdadero y sana heridas del pasado.',
    'locked': true,
  },
  {
    'title': 'Ritual de Dominio y Poder Personal',
    'description': 'Potencia tu seguridad, carisma y capacidad de influencia en todas las áreas de tu vida.',
    'locked': true,
  },
];

class RitualesScreen extends StatelessWidget {
  const RitualesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final user = Provider.of<AuthService>(context).userModel;
    final isSubscribed = user?.isSubscribed ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF06020F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0520), Color(0xFF06020F), Color(0xFF06020F)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<ContentFileModel>>(
            stream: db.streamContentByCategory('ritual'),
            builder: (context, snapshot) {
              final ritualesFirestore = snapshot.data ?? [];

              // Si Firestore tiene rituales, usarlos. Si no, mostrar muestra.
              final usarMuestra = ritualesFirestore.isEmpty;

              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  // Banner de suscripción si no está suscrito
                  if (!isSubscribed)
                    SliverToBoxAdapter(child: _buildSubscriptionBanner(context)),

                  // Lista de rituales
                  if (usarMuestra)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _RitualCardMuestra(
                            data: _ritualesMuestra[index],
                            isSubscribed: isSubscribed,
                            onContactar: () => _abrirWhatsApp(context),
                          ),
                          childCount: _ritualesMuestra.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final ritual = ritualesFirestore[index];
                            return _RitualCardFirestore(
                              ritual: ritual,
                              isSubscribed: isSubscribed,
                            );
                          },
                          childCount: ritualesFirestore.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RITUALES',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'Prácticas sagradas del maestro',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6B2FA0), Color(0xFF3D1166)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A017).withOpacity(0.15),
            const Color(0xFF6B2FA0).withOpacity(0.15),
          ],
        ),
        border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4A017), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los rituales completos son exclusivos para miembros. Contáctanos para activar tu membresía.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirWhatsApp(BuildContext context) async {
    // El enlace se obtiene de Firestore config
    final link = await DatabaseService().getWhatsAppLink();
    if (link.isNotEmpty) {
      final uri = Uri.parse(link);
      // ignore: deprecated_member_use
      if (await canLaunchUrl(uri)) {
        // ignore: deprecated_member_use
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

// ─── Card para rituales de muestra ───────────────────────────────────────────
class _RitualCardMuestra extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSubscribed;
  final VoidCallback onContactar;

  const _RitualCardMuestra({
    required this.data,
    required this.isSubscribed,
    required this.onContactar,
  });

  @override
  Widget build(BuildContext context) {
    final locked = (data['locked'] as bool) && !isSubscribed;
    return _RitualCardBase(
      title: data['title'] as String,
      description: data['description'] as String,
      locked: locked,
      onTap: locked
          ? () => _mostrarAvisoSub(context)
          : () => _mostrarDetalle(context),
    );
  }

  void _mostrarAvisoSub(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13082A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: const Color(0xFFD4A017).withOpacity(0.5)),
        ),
        title: Text(
          'Contenido Exclusivo',
          style: GoogleFonts.cinzel(color: const Color(0xFFD4A017), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Este ritual es exclusivo para miembros activos. Contacta al maestro para activar tu membresía y acceder a todo el contenido.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CERRAR', style: GoogleFonts.inter(color: Colors.white38)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onContactar();
            },
            icon: const Icon(Icons.chat_outlined, size: 16),
            label: const Text('CONTACTAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13082A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data['title'] as String,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4A017),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data['description'] as String,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.7),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B2FA0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('CERRAR', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card para rituales de Firestore ─────────────────────────────────────────
class _RitualCardFirestore extends StatelessWidget {
  final ContentFileModel ritual;
  final bool isSubscribed;

  const _RitualCardFirestore({required this.ritual, required this.isSubscribed});

  @override
  Widget build(BuildContext context) {
    return _RitualCardBase(
      title: ritual.title,
      description: ritual.description,
      locked: !isSubscribed,
      onTap: () {
        if (isSubscribed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(title: ritual.title, url: ritual.url),
            ),
          );
        } else {
          _mostrarAvisoSub(context);
        }
      },
    );
  }

  void _mostrarAvisoSub(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13082A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: const Color(0xFFD4A017).withOpacity(0.5)),
        ),
        title: Text('Contenido Exclusivo',
            style: GoogleFonts.cinzel(color: const Color(0xFFD4A017), fontWeight: FontWeight.bold)),
        content: Text(
          'Este ritual es exclusivo para miembros activos.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CERRAR', style: GoogleFonts.inter(color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}

// ─── Card base compartida ─────────────────────────────────────────────────────
class _RitualCardBase extends StatelessWidget {
  final String title;
  final String description;
  final bool locked;
  final VoidCallback onTap;

  const _RitualCardBase({
    required this.title,
    required this.description,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0A30).withOpacity(0.8),
            const Color(0xFF0D0520).withOpacity(0.9),
          ],
        ),
        border: Border.all(
          color: locked
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFF9C27B0).withOpacity(0.5),
          width: locked ? 1 : 1.5,
        ),
        boxShadow: locked
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: locked
                          ? [Colors.white12, Colors.white.withOpacity(0.05)]
                          : [const Color(0xFF6B2FA0), const Color(0xFF3D1166)],
                    ),
                  ),
                  child: Icon(
                    locked ? Icons.lock_outline_rounded : Icons.auto_fix_high_rounded,
                    color: locked ? Colors.white38 : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cinzel(
                          color: locked ? Colors.white54 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      if (locked) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: Color(0xFFD4A017), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Solo para miembros',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4A017),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                  color: locked ? Colors.white24 : const Color(0xFF9C27B0),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
