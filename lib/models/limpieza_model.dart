class LimpiezaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String instrucciones;
  final String duracion;
  final String categoria; // 'cuerpo', 'alma', 'espiritu', 'negocios', etc.
  final int orden;

  LimpiezaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.instrucciones = '',
    this.duracion = '',
    this.categoria = '',
    this.orden = 0,
  });

  factory LimpiezaModel.fromMap(Map<String, dynamic> map, String id) {
    return LimpiezaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      instrucciones: map['instrucciones'] ?? '',
      duracion: map['duracion'] ?? '',
      categoria: map['categoria'] ?? '',
      orden: map['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'instrucciones': instrucciones,
      'duracion': duracion,
      'categoria': categoria,
      'orden': orden,
    };
  }
}
