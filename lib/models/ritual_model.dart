class RitualModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String instrucciones;
  final String tipo; // 'sanación', 'abre caminos', 'atracción', 'dinero', 'trabajo', 'energías', 'vecinos'
  final int orden;

  RitualModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.instrucciones = '',
    this.tipo = 'sanación',
    this.orden = 0,
  });

  factory RitualModel.fromMap(Map<String, dynamic> map, String id) {
    return RitualModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      instrucciones: map['instrucciones'] ?? '',
      tipo: map['tipo'] ?? 'sanación',
      orden: map['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'instrucciones': instrucciones,
      'tipo': tipo,
      'orden': orden,
    };
  }
}
