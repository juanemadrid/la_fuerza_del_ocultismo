class TarotCardModel {
  final String id;
  final String nombre;
  final String significado;
  final String descripcionExtendida;
  final int orden;
  final String? imageUrl;

  TarotCardModel({
    required this.id,
    required this.nombre,
    required this.significado,
    this.descripcionExtendida = '',
    this.orden = 0,
    this.imageUrl,
  });

  factory TarotCardModel.fromMap(Map<String, dynamic> map, String id) {
    String name = map['nombre'] ?? '';
    if (name == 'Carna Negra') {
      name = 'Carta Negra';
    }
    return TarotCardModel(
      id: id,
      nombre: name,
      significado: map['significado'] ?? '',
      descripcionExtendida: map['descripcionExtendida'] ?? '',
      orden: map['orden'] ?? 0,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'significado': significado,
      'descripcionExtendida': descripcionExtendida,
      'orden': orden,
      'imageUrl': imageUrl,
    };
  }
}
