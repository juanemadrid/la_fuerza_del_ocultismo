class PlanModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int dias;
  final bool activo;
  final List<String> beneficios;
  final int orden;

  PlanModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.dias,
    this.activo = true,
    this.beneficios = const [],
    this.orden = 0,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map, String id) {
    return PlanModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      dias: map['dias'] ?? 30,
      activo: map['activo'] ?? true,
      beneficios: List<String>.from(map['beneficios'] ?? []),
      orden: map['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'dias': dias,
      'activo': activo,
      'beneficios': beneficios,
      'orden': orden,
    };
  }

  String get precioFormateado {
    if (precio == precio.truncateToDouble()) {
      return '\$${precio.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return '\$${precio.toStringAsFixed(0)}';
  }
}
