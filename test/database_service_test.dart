import 'package:flutter_test/flutter_test.dart';
import 'package:la_fuerza_del_ocultismo/services/database_service.dart';

void main() {
  group('DatabaseService Singleton and Cache Tests', () {
    test('DatabaseService should be a singleton instance', () {
      final db1 = DatabaseService();
      final db2 = DatabaseService();
      expect(identical(db1, db2), isTrue);
    });

    test('clearCache resets cached items', () {
      final db = DatabaseService();
      db.clearCache();
      expect(db.cachedWhatsAppLink, isNull);
      expect(db.cachedAppConfig, isNull);
      expect(db.cachedTarotCards, isNull);
      expect(db.cachedLimpiezas, isNull);
      expect(db.cachedRituales, isNull);
      expect(db.cachedPlanes, isNull);
    });
  });
}
