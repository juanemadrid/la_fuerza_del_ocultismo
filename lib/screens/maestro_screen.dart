import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';

class MaestroScreen extends StatelessWidget {
  const MaestroScreen({super.key});

  static const _testimonios = [
    {
      'nombre': 'María C.',
      'signo': '♐ Sagitario',
      'texto': 'Después de la limpieza profunda que me hizo el maestro, mi vida cambió completamente. En dos semanas conseguí trabajo y sané mi relación con mi familia. Eternamente agradecida.',
      'estrellas': 5,
    },
    {
      'nombre': 'Carlos M.',
      'signo': '♑ Capricornio',
      'texto': 'Llevaba 3 años con la empresa en quiebra. El ritual de abundancia que realizamos fue increíble. Hoy tengo un nuevo socio y el negocio está prosperando como nunca.',
      'estrellas': 5,
    },
    {
      'nombre': 'Laura R.',
      'signo': '♓ Piscis',
      'texto': 'El maestro me hizo el trabajo de amor y mi pareja volvió. Pero más importante, me ayudó a entender las energías que me rodeaban. Un guía excepcional.',
      'estrellas': 5,
    },
    {
      'nombre': 'Roberto A.',
      'signo': '♏ Escorpio',
      'texto': 'Tenía una envidia muy fuerte en el trabajo. Sentía que todo se me cerraba. Con la protección espiritual del maestro, los obstáculos desaparecieron en 30 días.',
      'estrellas': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06020F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0520), Color(0xFF06020F), Color(0xFF030008)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Perfil del maestro
            SliverToBoxAdapter(child: _buildPerfilMaestro()),

            // Especialidades
            SliverToBoxAdapter(child: _buildEspecialidades()),

            // Testimonios
            SliverToBoxAdapter(child: _buildSeccionTestimonios()),

            // Botón de contacto
            SliverToBoxAdapter(child: _buildBotonContacto(context)),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'EL MAESTRO',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilMaestro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          // Foto / avatar del maestro
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B2FA0), Color(0xFF3D1166), Color(0xFF1A0A30)],
              ),
              border: Border.all(color: const Color(0xFFD4A017), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color(0xFFD4A017).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, size: 70, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          Text(
            'MAESTRO LEYSON',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Espiritista · Tarotista · Sanador Energético',
            style: GoogleFonts.inter(
              color: const Color(0xFFD4A017),
              fontSize: 13,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 16),
              const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 16),
              const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 16),
              const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 16),
              const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 16),
              const SizedBox(width: 8),
              Text(
                '+ de 1,000 consultas realizadas',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Descripción
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A0A30).withOpacity(0.8),
                  const Color(0xFF0D0520).withOpacity(0.8),
                ],
              ),
              border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.25)),
            ),
            child: Text(
              'Con más de 15 años de experiencia en las ciencias ocultas, el Maestro Leyson ha guiado a cientos de personas en su camino espiritual. Su don para conectar con las energías universales le permite identificar bloqueos, realizar limpiezas profundas y ejecutar trabajos espirituales con resultados comprobados.\n\nEspecializado en espiritismo, tarot, limpiezas energéticas, rituales de amor, prosperidad y protección, el maestro ofrece un acompañamiento personalizado y confidencial a cada consultante.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13.5,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspecialidades() {
    final especialidades = [
      {'icono': Icons.auto_awesome_rounded, 'nombre': 'Tarot', 'desc': 'Lecturas del pasado, presente y futuro', 'color': const Color(0xFF9C27B0)},
      {'icono': Icons.water_drop_rounded, 'nombre': 'Limpiezas', 'desc': 'Purificación energética profunda', 'color': const Color(0xFF1565C0)},
      {'icono': Icons.auto_fix_high_rounded, 'nombre': 'Rituales', 'desc': 'Amor, dinero, trabajo y salud', 'color': const Color(0xFF6B2FA0)},
      {'icono': Icons.shield_moon_rounded, 'nombre': 'Protección', 'desc': 'Escudo contra envidias y mal de ojo', 'color': const Color(0xFF8B0000)},
      {'icono': Icons.stars_rounded, 'nombre': 'Horóscopo', 'desc': 'Predicciones personalizadas', 'color': const Color(0xFFB8860B)},
      {'icono': Icons.healing_rounded, 'nombre': 'Sanación', 'desc': 'Equilibrio del cuerpo y el alma', 'color': const Color(0xFF2E7D32)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESPECIALIDADES',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFD4A017),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: especialidades.length,
            itemBuilder: (context, index) {
              final e = especialidades[index];
              final color = e['color'] as Color;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  ),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(e['icono'] as IconData, color: color, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      e['nombre'] as String,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        e['desc'] as String,
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 9,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTestimonios() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TESTIMONIOS REALES',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFD4A017),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Personas reales que transformaron su vida',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ..._testimonios.map((t) => _TestimonioCard(data: t)),
        ],
      ),
    );
  }

  Widget _buildBotonContacto(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Text(
            '¿Listo para transformar tu vida?',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'El maestro está disponible para una consulta personalizada.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: DatabaseService().getWhatsAppLink(),
            builder: (context, snapshot) {
              final link = snapshot.data ?? '';
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: link.isNotEmpty
                      ? () async {
                          final msg = Uri.encodeComponent(
                            '¡Hola Maestro Leyson! Vi tu app y me interesa una consulta espiritual. ¿Puedes orientarme?',
                          );
                          final uri = Uri.parse('$link?text=$msg');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.chat_rounded, size: 22),
                  label: Text(
                    'CONSULTAR AL MAESTRO',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Testimonio Card ──────────────────────────────────────────────────────────
class _TestimonioCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TestimonioCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final estrellas = data['estrellas'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0A30).withOpacity(0.7),
            const Color(0xFF0D0520).withOpacity(0.8),
          ],
        ),
        border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B2FA0), Color(0xFF3D1166)],
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nombre'] as String,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data['signo'] as String,
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  estrellas,
                  (_) => const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${data['texto']}"',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 13,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
