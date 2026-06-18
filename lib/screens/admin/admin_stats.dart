import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

class AdminStats extends StatefulWidget {
  const AdminStats({super.key});

  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> {
  int _clientesVisibles = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'ESTADÍSTICAS',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: StreamBuilder<List<UserModel>>(
          stream: DatabaseService().streamUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final allUsers = snapshot.data!;
            final clientes =
                allUsers.where((u) => u.role != 'admin').toList();
            final suscritos =
                clientes.where((u) => u.isMembershipActive).toList();
            final noSuscritos =
                clientes.where((u) => !u.isSubscribed).toList();
            final conSigno =
                clientes.where((u) => u.zodiacSign.isNotEmpty).toList();
            final pendientes = clientes
                .where((u) =>
                    u.pendingApproval && u.subscriptionExpiry == null)
                .toList();

            // Próximos a vencer (≤7 días, membresía activa)
            final proximosVencer = clientes
                .where((u) =>
                    u.isMembershipActive &&
                    u.daysRemaining <= 7 &&
                    u.daysRemaining >= 0)
                .toList()
              ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

            // Estimado de ingresos (días vendidos × precio asumido $10 USD)
            const double precioPorDia = 10.0 / 30.0; // $10/mes
            double ingresoEstimado = 0;
            for (final u in clientes) {
              if (u.subscriptionExpiry != null) {
                // Estimate based on days from now to expiry (active only)
                if (u.isMembershipActive) {
                  ingresoEstimado += u.daysRemaining * precioPorDia;
                }
              }
            }

            // Conteo por signo zodiacal
            final Map<String, int> signoCounts = {};
            for (final u in clientes) {
              if (u.zodiacSign.isNotEmpty) {
                signoCounts[u.zodiacSign] =
                    (signoCounts[u.zodiacSign] ?? 0) + 1;
              }
            }
            final signosOrdenados = signoCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary cards ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          titulo: 'TOTAL\nCLIENTES',
                          valor: '${clientes.length}',
                          icono: Icons.people_outline,
                          color: const Color(0xFFB71C1C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          titulo: 'MEMBRESÍAS\nACTIVAS',
                          valor: '${suscritos.length}',
                          icono: Icons.verified_outlined,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          titulo: 'SIN\nSUSCRIPCIÓN',
                          valor: '${noSuscritos.length}',
                          icono: Icons.block_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          titulo: 'PENDIENTES\nAPROBACIÓN',
                          valor: '${pendientes.length}',
                          icono: Icons.pending_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          titulo: 'CON SIGNO\nCONFIG.',
                          valor: '${conSigno.length}',
                          icono: Icons.star_outline,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          titulo: 'INGRESO\nESTIMADO',
                          valor:
                              '\$${ingresoEstimado.toStringAsFixed(0)}',
                          icono: Icons.attach_money_outlined,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Subscription rate ─────────────────────────────────
                  _buildSectionTitle(
                      'TASA DE SUSCRIPCIÓN', Icons.pie_chart_outline),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFB71C1C).withOpacity(0.4)),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Suscritos activos',
                                style: TextStyle(color: Colors.white70)),
                            Text(
                              clientes.isEmpty
                                  ? '0%'
                                  : '${((suscritos.length / clientes.length) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: clientes.isEmpty
                                ? 0
                                : suscritos.length / clientes.length,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Próximos a vencer ─────────────────────────────────
                  if (proximosVencer.isNotEmpty) ...[
                    _buildSectionTitle(
                        'PRÓXIMOS A VENCER (≤7 días)',
                        Icons.warning_amber_outlined,
                        color: Colors.orange),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.4)),
                        color: Colors.orange.withOpacity(0.04),
                      ),
                      child: Column(
                        children: proximosVencer
                            .map((u) => _VencimientoTile(user: u))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Popular signs ─────────────────────────────────────
                  if (signosOrdenados.isNotEmpty) ...[
                    _buildSectionTitle(
                        'SIGNOS MÁS POPULARES', Icons.star_outline),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFB71C1C).withOpacity(0.4)),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Column(
                        children: signosOrdenados.take(5).map((entry) {
                          final porcentaje = conSigno.isEmpty
                              ? 0.0
                              : entry.value / conSigno.length;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                    Text(
                                      '${entry.value} usuario${entry.value != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: Color(0xFFB71C1C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: porcentaje,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFB71C1C)),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── All clients with pagination ────────────────────────
                  _buildSectionTitle(
                      'TODOS LOS CLIENTES', Icons.people_outline),
                  const SizedBox(height: 12),
                  if (clientes.isEmpty)
                    const Center(
                      child: Text(
                        'No hay clientes registrados',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  else ...[
                    ...clientes
                        .take(_clientesVisibles)
                        .map((user) => _ClienteTile(user: user)),
                    if (_clientesVisibles < clientes.length) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(
                              () => _clientesVisibles += 10),
                          icon: const Icon(Icons.expand_more,
                              color: Color(0xFFB71C1C)),
                          label: Text(
                            'VER MÁS (${clientes.length - _clientesVisibles} restantes)',
                            style: const TextStyle(
                                color: Color(0xFFB71C1C)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFB71C1C)),
                          ),
                        ),
                      ),
                    ] else if (clientes.length > 10) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _clientesVisibles = 10),
                          icon: const Icon(Icons.expand_less,
                              color: Colors.white38),
                          label: const Text(
                            'MOSTRAR MENOS',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon,
      {Color color = const Color(0xFFB71C1C)}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
        color: color.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vencimiento Tile ─────────────────────────────────────────────────────────

class _VencimientoTile extends StatelessWidget {
  final UserModel user;

  const _VencimientoTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final days = user.daysRemaining;
    final urgency = days == 0
        ? Colors.red
        : days <= 2
            ? Colors.deepOrange
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: urgency.withOpacity(0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: urgency, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Sin nombre',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  user.email,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: urgency.withOpacity(0.15),
              border: Border.all(color: urgency.withOpacity(0.5)),
            ),
            child: Text(
              days == 0 ? 'HOY' : '${days}d',
              style: TextStyle(
                color: urgency,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cliente Tile ─────────────────────────────────────────────────────────────

class _ClienteTile extends StatelessWidget {
  final UserModel user;

  const _ClienteTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFB71C1C).withOpacity(0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Sin nombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  user.email,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                if (user.zodiacSign.isNotEmpty)
                  Text(
                    user.zodiacSign,
                    style: const TextStyle(
                        color: Color(0xFFB71C1C), fontSize: 10),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: user.isMembershipActive
                      ? Colors.green.withOpacity(0.2)
                      : user.subscriptionExpiry != null
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: user.isMembershipActive
                        ? Colors.green
                        : user.subscriptionExpiry != null
                            ? Colors.orange
                            : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  user.isMembershipActive
                      ? 'ACTIVO'
                      : user.subscriptionExpiry != null
                          ? 'VENCIDO'
                          : 'INACTIVO',
                  style: TextStyle(
                    color: user.isMembershipActive
                        ? Colors.green
                        : user.subscriptionExpiry != null
                            ? Colors.orange
                            : Colors.grey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user.isMembershipActive) ...[
                const SizedBox(height: 2),
                Text(
                  '${user.daysRemaining}d',
                  style: const TextStyle(
                      color: Colors.green, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
