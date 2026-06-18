import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/limpieza_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// Datos de muestra para mostrar cuando Firestore está vacío
const _limpiezasMuestra = [
  {
    'nombre': 'Limpieza Energética Básica',
    'descripcion': 'Elimina las cargas negativas del día a día y restaura tu campo energético.',
    'duracion': '30 minutos',
    'categoria': 'Básica',
    'locked': false,
    'instrucciones': 'Esta limpieza se realiza con sal gruesa, agua bendita e incienso de mirra. El maestro guía el proceso de forma personalizada según tu caso.',
  },
  {
    'nombre': 'Limpieza Profunda de Espíritus',
    'descripcion': 'Expulsa entidades y presencias negativas que afectan tu salud, trabajo y relaciones.',
    'duracion': '90 minutos',
    'categoria': 'Avanzada',
    'locked': true,
    'instrucciones': '',
  },
  {
    'nombre': 'Limpieza de Casa u Oficina',
    'descripcion': 'Purifica los espacios físicos que habitas para atraer armonía, paz y prosperidad.',
    'duracion': '60 minutos',
    'categoria': 'Espacios',
    'locked': true,
    'instrucciones': '',
  },
  {
    'nombre': 'Limpieza de Camino (Desbloqueo)',
    'descripcion': 'Elimina bloqueos en el amor, el dinero o el trabajo que te impiden avanzar.',
    'duracion': '45 minutos',
    'categoria': 'Especial',
    'locked': true,
    'instrucciones': '',
  },
  {
    'nombre': 'Limpieza Ancestral',
    'descripcion': 'Trabaja en herencias espirituales y karmas familiares que afectan tu línea de vida.',
    'duracion': '2 horas',
    'categoria': 'Premium',
    'locked': true,
    'instrucciones': '',
  },
];

class LimpiezasScreen extends StatelessWidget {
  const LimpiezasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final isSubscribed = user?.isSubscribed ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF06020F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF080315), Color(0xFF06020F), Color(0xFF06020F)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<LimpiezaModel>>(
            stream: DatabaseService().streamLimpiezas(),
            builder: (context, snapshot) {
              final limpiezasFirestore = snapshot.data ?? [];
              final usarMuestra = limpiezasFirestore.isEmpty;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  if (!isSubscribed)
                    SliverToBoxAdapter(child: _buildSubscriptionBanner()),

                  if (usarMuestra)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _LimpiezaCardMuestra(
                            data: _limpiezasMuestra[index],
                            isSubscribed: isSubscribed,
                            onContactar: () => _abrirWhatsApp(context),
                          ),
                          childCount: _limpiezasMuestra.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _LimpiezaCardFirestore(
                            limpieza: limpiezasFirestore[index],
                            isSubscribed: isSubscribed,
                          ),
                          childCount: limpiezasFirestore.length,
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
                  'LIMPIEZAS',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'Purificación y equilibrio espiritual',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D2B5C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A017).withOpacity(0.15),
            const Color(0xFF1565C0).withOpacity(0.15),
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
              'Las instrucciones detalladas son exclusivas para miembros activos.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirWhatsApp(BuildContext context) async {
    final link = await DatabaseService().getWhatsAppLink();
    if (link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

// ─── Card muestra ──────────────────────────────────────────────────────────────
class _LimpiezaCardMuestra extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSubscribed;
  final VoidCallback onContactar;

  const _LimpiezaCardMuestra({
    required this.data,
    required this.isSubscribed,
    required this.onContactar,
  });

  @override
  Widget build(BuildContext context) {
    final locked = (data['locked'] as bool) && !isSubscribed;
    return _LimpiezaCardBase(
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String,
      duracion: data['duracion'] as String,
      categoria: data['categoria'] as String,
      locked: locked,
      onTap: () => _mostrarDetalle(context, locked),
    );
  }

  void _mostrarDetalle(BuildContext context, bool locked) {
    if (locked) {
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
            'Las instrucciones de esta limpieza son exclusivas para miembros activos. Contacta al maestro para activar tu membresía.',
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
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13082A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(data['nombre'] as String,
                  style: GoogleFonts.cinzel(color: const Color(0xFFD4A017), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text((data['categoria'] as String).toUpperCase(),
                    style: GoogleFonts.inter(color: const Color(0xFF64B5F6), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),
              Text(data['descripcion'] as String,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.7)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: Color(0xFFD4A017), size: 16),
                  const SizedBox(width: 8),
                  Text('Duración: ${data['duracion']}',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                ],
              ),
              if ((data['instrucciones'] as String).isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Text('INSTRUCCIONES',
                    style: GoogleFonts.cinzel(color: const Color(0xFFD4A017), fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 12),
                Text(data['instrucciones'] as String,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.7)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
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

// ─── Card Firestore ────────────────────────────────────────────────────────────
class _LimpiezaCardFirestore extends StatelessWidget {
  final LimpiezaModel limpieza;
  final bool isSubscribed;

  const _LimpiezaCardFirestore({required this.limpieza, required this.isSubscribed});

  @override
  Widget build(BuildContext context) {
    return _LimpiezaCardBase(
      nombre: limpieza.nombre,
      descripcion: limpieza.descripcion,
      duracion: limpieza.duracion,
      categoria: limpieza.categoria,
      locked: !isSubscribed,
      onTap: () => _mostrarDetalle(context),
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
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(limpieza.nombre,
                  style: GoogleFonts.cinzel(color: const Color(0xFFD4A017), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Text(limpieza.descripcion,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.7)),
              if (limpieza.instrucciones.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                if (isSubscribed)
                  Text(limpieza.instrucciones,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.7))
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.4)),
                      color: const Color(0xFFD4A017).withOpacity(0.08),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFFD4A017), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las instrucciones son exclusivas para miembros activos.',
                            style: GoogleFonts.inter(color: const Color(0xFFD4A017), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
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

// ─── Card base compartida ─────────────────────────────────────────────────────
class _LimpiezaCardBase extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String duracion;
  final String categoria;
  final bool locked;
  final VoidCallback onTap;

  const _LimpiezaCardBase({
    required this.nombre,
    required this.descripcion,
    required this.duracion,
    required this.categoria,
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
            const Color(0xFF0A1628).withOpacity(0.9),
            const Color(0xFF06020F).withOpacity(0.9),
          ],
        ),
        border: Border.all(
          color: locked
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFF1565C0).withOpacity(0.5),
          width: locked ? 1 : 1.5,
        ),
        boxShadow: locked
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.12),
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: locked
                          ? [Colors.white12, Colors.white.withOpacity(0.05)]
                          : [const Color(0xFF1565C0), const Color(0xFF0D2B5C)],
                    ),
                  ),
                  child: Icon(
                    locked ? Icons.lock_outline_rounded : Icons.water_drop_rounded,
                    color: locked ? Colors.white38 : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: GoogleFonts.cinzel(
                          color: locked ? Colors.white54 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, height: 1.4),
                      ),
                      if (duracion.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              locked ? Icons.workspace_premium_rounded : Icons.access_time_rounded,
                              color: locked ? const Color(0xFFD4A017) : const Color(0xFF64B5F6),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locked ? 'Solo para miembros' : duracion,
                              style: GoogleFonts.inter(
                                color: locked ? const Color(0xFFD4A017) : const Color(0xFF64B5F6),
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
                  color: locked ? Colors.white24 : const Color(0xFF1565C0),
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
