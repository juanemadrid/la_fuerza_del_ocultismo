import 'package:flutter_test/flutter_test.dart';
import 'package:la_fuerza_del_ocultismo/models/user_model.dart';

void main() {
  group('Auth Model and Access Role Tests', () {
    test('Admin role verification logic', () {
      final admin = UserModel(
        uid: 'admin_1',
        name: 'Maestro Leyson',
        email: 'maestro@ocultismo.com',
        role: 'admin',
        isSubscribed: true,
        zodiacSign: '',
        pendingApproval: false,
      );

      expect(admin.role, 'admin');
      expect(admin.isSubscribed, isTrue);
    });

    test('Standard user default state', () {
      final user = UserModel(
        uid: 'user_1',
        name: 'Nuevo Usuario',
        email: 'nuevo@ocultismo.com',
        role: 'user',
        isSubscribed: false,
        zodiacSign: '',
        pendingApproval: false,
      );

      expect(user.role, 'user');
      expect(user.isSubscribed, isFalse);
      expect(user.pendingApproval, isFalse);
    });
  });
}
