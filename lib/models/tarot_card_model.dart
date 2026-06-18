class TarotCardModel {
  final String id;
  final String nombre;
  final String significado;
  final String descripcionExtendida;
  final int orden;

  TarotCardModel({
    required this.id,
    required this.nombre,
    required this.significado,
    this.descripcionExtendida = '',
    this.orden = 0,
  });

  factory TarotCardModel.fromMap(Map<String, dynamic> map, String id) {
    return TarotCardModel(
      id: id,
      nombre: map['nombre'] ?? '',
      significado: map['significado'] ?? '',
      descripcionExtendida: map['descripcionExtendida'] ?? '',
      orden: map['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'significado': significado,
      'descripcionExtendida': descripcionExtendida,
      'orden': orden,
    };
  }
}
