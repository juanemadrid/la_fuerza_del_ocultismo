import 'package:flutter_test/flutter_test.dart';
import 'package:la_fuerza_del_ocultismo/models/user_model.dart';
import 'package:la_fuerza_del_ocultismo/models/plan_model.dart';
import 'package:la_fuerza_del_ocultismo/models/tarot_card_model.dart';

void main() {
  group('Model Serialization & Integrity Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        uid: 'user123',
        name: 'Consultante Astral',
        email: 'astral@ocultismo.com',
        role: 'user',
        isSubscribed: true,
        zodiacSign: 'Escorpio',
        birthDate: '1990-10-24',
        pendingApproval: false,
      );

      final map = user.toMap();
      expect(map['name'], 'Consultante Astral');
      expect(map['email'], 'astral@ocultismo.com');
      expect(map['isSubscribed'], isTrue);

      final restored = UserModel.fromMap(map, 'user123');
      expect(restored.uid, 'user123');
      expect(restored.name, 'Consultante Astral');
      expect(restored.zodiacSign, 'Escorpio');
    });

    test('PlanModel serialization and properties', () {
      final plan = PlanModel(
        id: 'plan_mensual',
        nombre: 'Iniciación Mística',
        descripcion: 'Acceso a todas las lecturas por 30 días',
        precio: 9.99,
        dias: 30,
        orden: 1,
        activo: true,
      );

      final map = plan.toMap();
      expect(map['nombre'], 'Iniciación Mística');
      expect(map['precio'], 9.99);
      expect(map['dias'], 30);

      final restored = PlanModel.fromMap(map, 'plan_mensual');
      expect(restored.id, 'plan_mensual');
      expect(restored.dias, 30);
      expect(restored.activo, isTrue);
    });

    test('TarotCardModel properties and fallback', () {
      final card = TarotCardModel(
        id: 'carta_1',
        nombre: 'El Mago',
        significado: 'Poder, habilidad, concentración, acción.',
        orden: 1,
      );

      expect(card.id, 'carta_1');
      expect(card.nombre, 'El Mago');
      expect(card.orden, 1);
    });
  });
}
