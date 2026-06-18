import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

// Filter options
enum _UserFilter { todos, pendientes, activos, vencidos }

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _searchController = TextEditingController();
  _UserFilter _activeFilter = _UserFilter.todos;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _applyFilters(List<UserModel> users) {
    var filtered = users.where((u) => u.role != 'admin').toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    // Apply filter chip
    switch (_activeFilter) {
      case _UserFilter.pendientes:
        filtered = filtered
            .where((u) => u.pendingApproval && u.subscriptionExpiry == null)
            .toList();
        break;
      case _UserFilter.activos:
        filtered = filtered.where((u) => u.isMembershipActive).toList();
        break;
      case _UserFilter.vencidos:
        filtered = filtered
            .where((u) =>
                u.subscriptionExpiry != null && !u.isMembershipActive)
            .toList();
        break;
      case _UserFilter.todos:
        break;
    }

    // Pendientes primero
    filtered.sort((a, b) {
      if (a.pendingApproval && a.subscriptionExpiry == null) return -1;
      if (b.pendingApproval && b.subscriptionExpiry == null) return 1;
      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR CLIENTES',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Color(0xFFB71C1C)),
            tooltip: 'Crear usuario',
            onPressed: () => _mostrarDialogoCrear(context),
          ),
        ],
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

            final allClientes = snapshot.data!
                .where((u) => u.role != 'admin')
                .toList();
            final pendientesCount = allClientes
                .where((u) =>
                    u.pendingApproval && u.subscriptionExpiry == null)
                .length;
            final activosCount =
                allClientes.where((u) => u.isMembershipActive).length;
            final vencidosCount = allClientes
                .where((u) =>
                    u.subscriptionExpiry != null && !u.isMembershipActive)
                .length;

            final filtered = _applyFilters(snapshot.data!);

            return Column(
              children: [
                // ── Search bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o correo...',
                      hintStyle: const TextStyle(
                          color: Colors.white38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFB71C1C), size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.white38, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFB71C1C)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // ── Filter chips ────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'TODOS',
                        count: allClientes.length,
                        selected: _activeFilter == _UserFilter.todos,
                        color: Colors.white70,
                        onTap: () => setState(
                            () => _activeFilter = _UserFilter.todos),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'PENDIENTES',
                        count: pendientesCount,
                        selected:
                            _activeFilter == _UserFilter.pendientes,
                        color: Colors.orange,
                        onTap: () => setState(
                            () => _activeFilter = _UserFilter.pendientes),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'ACTIVOS',
                        count: activosCount,
                        selected: _activeFilter == _UserFilter.activos,
                        color: Colors.green,
                        onTap: () => setState(
                            () => _activeFilter = _UserFilter.activos),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'VENCIDOS',
                        count: vencidosCount,
                        selected: _activeFilter == _UserFilter.vencidos,
                        color: Colors.red,
                        onTap: () => setState(
                            () => _activeFilter = _UserFilter.vencidos),
                      ),
                    ],
                  ),
                ),

                // ── Pending banner ──────────────────────────────────────
                if (pendientesCount > 0 &&
                    _activeFilter == _UserFilter.todos &&
                    _searchQuery.isEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_outlined,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$pendientesCount cliente${pendientesCount != 1 ? 's' : ''} esperando activación de membresía',
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── List ────────────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline,
                                  color: Colors.white24, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Sin resultados para "$_searchQuery"'
                                    : 'No hay clientes en esta categoría',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _UserCard(user: filtered[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _CrearUsuarioDialog(),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: selected ? color : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.white54,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selected
                    ? color.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? color : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de usuario ───────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserModel user;

  const _UserCard({required this.user});

  static const List<String> _signs = [
    '', 'Aries', 'Tauro', 'Géminis', 'Cáncer', 'Leo', 'Virgo',
    'Libra', 'Escorpio', 'Sagitario', 'Capricornio', 'Acuario', 'Piscis',
  ];

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.4)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB71C1C).withOpacity(0.2),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name.isNotEmpty ? user.name : 'Sin nombre',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                _Badge(
                  label: user.isMembershipActive
                      ? 'ACTIVO · ${user.daysRemaining}d'
                      : user.subscriptionExpiry != null
                          ? 'VENCIDO'
                          : user.pendingApproval
                              ? 'PENDIENTE'
                              : 'INACTIVO',
                  color: user.isMembershipActive
                      ? Colors.green
                      : user.subscriptionExpiry != null
                          ? Colors.orange
                          : user.pendingApproval
                              ? Colors.blue
                              : Colors.grey,
                ),
                const SizedBox(width: 6),
                if (user.zodiacSign.isNotEmpty)
                  _Badge(label: user.zodiacSign, color: Colors.purple),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                // Suscripción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Suscripción activa',
                        style: TextStyle(color: Colors.white70)),
                    Switch(
                      value: user.isSubscribed,
                      activeColor: const Color(0xFFB71C1C),
                      onChanged: (val) {
                        if (val) {
                          // Al activar, mostrar selector de días
                          _mostrarActivarMembresia(context, user);
                        } else {
                          db.deactivateSubscription(user.uid);
                        }
                      },
                    ),
                  ],
                ),

                // Fecha de vencimiento
                if (user.subscriptionExpiry != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: user.isMembershipActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      border: Border.all(
                        color: user.isMembershipActive
                            ? Colors.green.withOpacity(0.4)
                            : Colors.red.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          user.isMembershipActive
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: user.isMembershipActive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.isMembershipActive
                                    ? 'Vence: ${_formatDate(user.subscriptionExpiry!)}'
                                    : 'Venció: ${_formatDate(user.subscriptionExpiry!)}',
                                style: TextStyle(
                                  color: user.isMembershipActive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (user.isMembershipActive)
                                Text(
                                  '${user.daysRemaining} día${user.daysRemaining != 1 ? 's' : ''} restante${user.daysRemaining != 1 ? 's' : ''}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _mostrarActivarMembresia(context, user),
                          child: const Text('RENOVAR',
                              style: TextStyle(color: Color(0xFFB71C1C), fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => _mostrarActivarMembresia(context, user),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('ACTIVAR MEMBRESÍA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 8),

                // Signo zodiacal
                Row(
                  children: [
                    const Text('Signo: ', style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _signs.contains(user.zodiacSign) ? user.zodiacSign : '',
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A1A1A),
                        underline: Container(height: 1, color: const Color(0xFFB71C1C)),
                        items: _signs.map((sign) => DropdownMenuItem(
                          value: sign,
                          child: Text(
                            sign.isEmpty ? 'Sin signo' : sign,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) db.updateUserZodiacSign(user.uid, value);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _mostrarDialogoEditar(context, user),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('EDITAR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmarEliminar(context, user),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('ELIMINAR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => _EditarUsuarioDialog(user: user),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _mostrarActivarMembresia(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => _ActivarMembresiaDialog(user: user),
    );
  }

  void _confirmarEliminar(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red),
        ),
        title: const Text(
          '¿Eliminar cliente?',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminará el perfil de ${user.name.isNotEmpty ? user.name : user.email} de Firestore.\n\nNota: la cuenta de Firebase Auth permanece activa.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deleteUserData(user.uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cliente eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

// ─── Diálogo editar usuario ───────────────────────────────────────────────────

class _EditarUsuarioDialog extends StatefulWidget {
  final UserModel user;
  const _EditarUsuarioDialog({required this.user});

  @override
  State<_EditarUsuarioDialog> createState() => _EditarUsuarioDialogState();
}

class _EditarUsuarioDialogState extends State<_EditarUsuarioDialog> {
  late TextEditingController _nameController;
  late String _role;
  late bool _isSubscribed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _role = widget.user.role;
    _isSubscribed = widget.user.isSubscribed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: const Text(
        'EDITAR CLIENTE',
        style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suscripción', style: TextStyle(color: Colors.white70)),
                Switch(
                  value: _isSubscribed,
                  activeColor: const Color(0xFFB71C1C),
                  onChanged: (val) => setState(() => _isSubscribed = val),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rol', style: TextStyle(color: Colors.white70)),
                DropdownButton<String>(
                  value: _role,
                  dropdownColor: const Color(0xFF1A1A1A),
                  items: ['user', 'admin'].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(
                      r.toUpperCase(),
                      style: TextStyle(
                        color: r == 'admin' ? const Color(0xFFB71C1C) : Colors.white,
                      ),
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _role = val!),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('GUARDAR'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    final db = DatabaseService();
    try {
      await db.updateUserName(widget.user.uid, _nameController.text.trim());
      await db.updateUserSubscription(widget.user.uid, _isSubscribed);
      await db.updateUserRole(widget.user.uid, _role);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente actualizado'),
            backgroundColor: Color(0xFFB71C1C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ─── Diálogo crear usuario ────────────────────────────────────────────────────

class _CrearUsuarioDialog extends StatefulWidget {
  const _CrearUsuarioDialog();

  @override
  State<_CrearUsuarioDialog> createState() => _CrearUsuarioDialogState();
}

class _CrearUsuarioDialogState extends State<_CrearUsuarioDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String _role = 'user';
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: const Text(
        'CREAR CLIENTE',
        style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_nameController, 'Nombre completo', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(_emailController, 'Correo electrónico', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildField(
              _passController,
              'Contraseña (mín. 6 caracteres)',
              Icons.lock_outline,
              obscure: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rol', style: TextStyle(color: Colors.white70)),
                DropdownButton<String>(
                  value: _role,
                  dropdownColor: const Color(0xFF1A1A1A),
                  items: ['user', 'admin'].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(
                      r.toUpperCase(),
                      style: TextStyle(
                        color: r == 'admin' ? const Color(0xFFB71C1C) : Colors.white,
                      ),
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _role = val!),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _crear,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('CREAR'),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFB71C1C), size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Future<void> _crear() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.createUserAsAdmin(email, pass, name, _role);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ─── Diálogo activar membresía ────────────────────────────────────────────────

class _ActivarMembresiaDialog extends StatefulWidget {
  final UserModel user;
  const _ActivarMembresiaDialog({required this.user});

  @override
  State<_ActivarMembresiaDialog> createState() => _ActivarMembresiaDialogState();
}

class _ActivarMembresiaDialogState extends State<_ActivarMembresiaDialog> {
  int _diasSeleccionados = 30;
  bool _extender = true;
  bool _saving = false;

  final List<Map<String, dynamic>> _opciones = [
    {'label': '7 días', 'dias': 7},
    {'label': '15 días', 'dias': 15},
    {'label': '30 días (1 mes)', 'dias': 30},
    {'label': '60 días (2 meses)', 'dias': 60},
    {'label': '90 días (3 meses)', 'dias': 90},
    {'label': '180 días (6 meses)', 'dias': 180},
    {'label': '365 días (1 año)', 'dias': 365},
  ];

  @override
  void initState() {
    super.initState();
    _diasSeleccionados = widget.user.pendingPlanDias ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    final tieneMembresia = widget.user.subscriptionExpiry != null &&
        widget.user.subscriptionExpiry!.isAfter(DateTime.now());

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.green),
      ),
      title: Text(
        tieneMembresia ? 'RENOVAR MEMBRESÍA' : 'ACTIVAR MEMBRESÍA',
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${widget.user.name.isNotEmpty ? widget.user.name : widget.user.email}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (widget.user.pendingPlanNombre != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB71C1C).withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFFB71C1C).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Plan solicitado: ${widget.user.pendingPlanNombre} · \$${(widget.user.pendingPlanPrecio ?? 0).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Duración:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            ..._opciones.map((op) => RadioListTile<int>(
              value: op['dias'] as int,
              groupValue: _diasSeleccionados,
              activeColor: Colors.green,
              title: Text(op['label'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (val) => setState(() => _diasSeleccionados = val!),
            )),
            if (tieneMembresia) ...[
              const Divider(color: Colors.white12),
              Row(
                children: [
                  Checkbox(
                    value: _extender,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _extender = val!),
                  ),
                  const Expanded(
                    child: Text(
                      'Extender desde la fecha actual de vencimiento',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green.withOpacity(0.08),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Vencerá el: ${_calcularFecha()}',
                    style: const TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _activar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('CONFIRMAR'),
        ),
      ],
    );
  }

  String _calcularFecha() {
    final tieneMembresia = widget.user.subscriptionExpiry != null &&
        widget.user.subscriptionExpiry!.isAfter(DateTime.now());
    DateTime base = DateTime.now();
    if (_extender && tieneMembresia) base = widget.user.subscriptionExpiry!;
    final fecha = base.add(Duration(days: _diasSeleccionados));
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Future<void> _activar() async {
    setState(() => _saving = true);
    try {
      await DatabaseService().activateSubscription(
        widget.user.uid,
        _diasSeleccionados,
        extendIfActive: _extender,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membresía activada por $_diasSeleccionados días'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ─── Badge helper ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
