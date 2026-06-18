import 'package:flutter/material.dart';
import '../../models/plan_model.dart';
import '../../services/database_service.dart';

class ManagePlanes extends StatelessWidget {
  const ManagePlanes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR PLANES',
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
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB71C1C)),
            onPressed: () => _mostrarDialogo(context, null),
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
        child: StreamBuilder<List<PlanModel>>(
          stream: DatabaseService().streamPlanes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final planes = snapshot.data!;

            if (planes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.card_membership_outlined,
                        color: Color(0xFFB71C1C), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay planes creados',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarDialogo(context, null),
                      icon: const Icon(Icons.add),
                      label: const Text('CREAR PRIMER PLAN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: planes.length,
              itemBuilder: (context, index) {
                final plan = planes[index];
                return _PlanTile(
                  plan: plan,
                  onEdit: () => _mostrarDialogo(context, plan),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, PlanModel? plan) {
    showDialog(
      context: context,
      builder: (_) => _PlanDialog(plan: plan),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback onEdit;

  const _PlanTile({required this.plan, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: plan.activo
              ? const Color(0xFFB71C1C).withOpacity(0.4)
              : Colors.white12,
        ),
        color: const Color(0xFF1A1A1A),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.nombre,
                            style: TextStyle(
                              color: plan.activo ? Colors.white : Colors.white38,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: plan.activo
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: plan.activo
                                    ? Colors.green.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              plan.activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                color: plan.activo ? Colors.green : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.precioFormateado} · ${plan.dias} días',
                        style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Acciones
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: plan.activo,
                      activeColor: const Color(0xFFB71C1C),
                      onChanged: (val) =>
                          DatabaseService().updatePlanStatus(plan.id, val),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Color(0xFFB71C1C), size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () => _confirmarEliminar(context),
                    ),
                  ],
                ),
              ],
            ),
            if (plan.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                plan.descripcion,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
            if (plan.beneficios.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.beneficios
                    .map((b) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            b,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red),
        ),
        title: const Text('¿Eliminar plan?',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminará el plan "${plan.nombre}". Los usuarios que lo tengan pendiente no se verán afectados.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deletePlan(plan.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _PlanDialog extends StatefulWidget {
  final PlanModel? plan;
  const _PlanDialog({this.plan});

  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _diasCtrl;
  late TextEditingController _beneficioCtrl;
  late List<String> _beneficios;
  late bool _activo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.plan?.nombre ?? '');
    _descripcionCtrl =
        TextEditingController(text: widget.plan?.descripcion ?? '');
    _precioCtrl = TextEditingController(
        text: widget.plan?.precio.toInt().toString() ?? '');
    _diasCtrl =
        TextEditingController(text: widget.plan?.dias.toString() ?? '30');
    _beneficioCtrl = TextEditingController();
    _beneficios = List<String>.from(widget.plan?.beneficios ?? []);
    _activo = widget.plan?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _diasCtrl.dispose();
    _beneficioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plan != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      title: Text(
        isEdit ? 'EDITAR PLAN' : 'NUEVO PLAN',
        style: const TextStyle(
            color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nombreCtrl, 'Nombre del plan'),
              const SizedBox(height: 10),
              _field(_descripcionCtrl, 'Descripción', maxLines: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _field(_precioCtrl, 'Precio (\$)',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(_diasCtrl, 'Días',
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Beneficios
              Row(
                children: [
                  Expanded(
                    child: _field(_beneficioCtrl, 'Agregar beneficio'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Color(0xFFB71C1C)),
                    onPressed: () {
                      if (_beneficioCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _beneficios.add(_beneficioCtrl.text.trim());
                          _beneficioCtrl.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_beneficios.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _beneficios
                      .map((b) => Chip(
                            label: Text(b,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            backgroundColor:
                                const Color(0xFFB71C1C).withOpacity(0.2),
                            deleteIconColor: Colors.white54,
                            onDeleted: () =>
                                setState(() => _beneficios.remove(b)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Plan activo',
                      style: TextStyle(color: Colors.white70)),
                  Switch(
                    value: _activo,
                    activeColor: const Color(0xFFB71C1C),
                    onChanged: (val) => setState(() => _activo = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR',
              style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C)),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'GUARDAR' : 'CREAR'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty || _precioCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);

    final id = widget.plan?.id ??
        'plan_${DateTime.now().millisecondsSinceEpoch}';
    final plan = PlanModel(
      id: id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      precio: double.tryParse(_precioCtrl.text.trim()) ?? 0,
      dias: int.tryParse(_diasCtrl.text.trim()) ?? 30,
      activo: _activo,
      beneficios: _beneficios,
      orden: widget.plan?.orden ?? DateTime.now().millisecondsSinceEpoch,
    );

    await DatabaseService().savePlan(plan);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.plan != null ? 'Plan actualizado' : 'Plan creado'),
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
    }
  }
}
