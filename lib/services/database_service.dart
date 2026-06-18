import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';
import '../models/content_file_model.dart';
import '../models/tarot_card_model.dart';
import '../models/limpieza_model.dart';
import '../models/ritual_model.dart';
import '../models/plan_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER METHODS ──────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _db.collection('user').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('user').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<UserModel>> streamUsers() {
    return _db.collection('user').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateUserSubscription(String uid, bool isSubscribed) async {
    await _db
        .collection('user')
        .doc(uid)
        .update({'isSubscribed': isSubscribed});
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String email,
    required String zodiacSign,
    required String birthDate,
  }) async {
    await _db.collection('user').doc(uid).update({
      'name': name,
      'email': email,
      'zodiacSign': zodiacSign,
      'birthDate': birthDate,
    });
  }

  Future<void> updateUserZodiacSign(String uid, String zodiacSign) async {
    await _db.collection('user').doc(uid).update({'zodiacSign': zodiacSign});
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('user').doc(uid).update({'role': role});
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection('user').doc(uid).delete();
  }

  Future<void> updateUserName(String uid, String name) async {
    await _db.collection('user').doc(uid).update({'name': name});
  }

  /// Activa la membresía por [days] días a partir de hoy.
  /// Si ya tiene membresía activa y [extendIfActive] es true, extiende desde la fecha actual de vencimiento.
  Future<void> activateSubscription(String uid, int days,
      {bool extendIfActive = false}) async {
    final doc = await _db.collection('user').doc(uid).get();
    DateTime base = DateTime.now();

    if (extendIfActive && doc.exists) {
      final data = doc.data()!;
      if (data['subscriptionExpiry'] != null) {
        final current =
            (data['subscriptionExpiry'] as dynamic).toDate() as DateTime;
        if (current.isAfter(base)) base = current;
      }
    }

    final expiry = base.add(Duration(days: days));
    await _db.collection('user').doc(uid).update({
      'isSubscribed': true,
      'subscriptionExpiry': expiry,
      'pendingApproval': false,
      'pendingPlanId': null,
      'pendingPlanNombre': null,
      'pendingPlanPrecio': null,
      'pendingPlanDias': null,
    });
  }

  /// Desactiva la membresía inmediatamente.
  Future<void> deactivateSubscription(String uid) async {
    await _db.collection('user').doc(uid).update({
      'isSubscribed': false,
      'subscriptionExpiry': DateTime.now().subtract(const Duration(days: 1)),
    });
  }

  /// Verifica y actualiza automáticamente si la membresía venció.
  Future<void> checkAndUpdateExpiredSubscription(String uid) async {
    final doc = await _db.collection('user').doc(uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    if (data['isSubscribed'] == true && data['subscriptionExpiry'] != null) {
      final expiry =
          (data['subscriptionExpiry'] as dynamic).toDate() as DateTime;
      if (expiry.isBefore(DateTime.now())) {
        await _db.collection('user').doc(uid).update({'isSubscribed': false});
      }
    }
  }

  // ─── HOROSCOPE METHODS ─────────────────────────────────────────────────────

  Future<void> updateHoroscope(HoroscopeModel horoscope) async {
    await _db
        .collection('horoscopes')
        .doc(horoscope.sign)
        .set(horoscope.toMap());
  }

  Future<HoroscopeModel?> getHoroscope(String sign) async {
    var doc = await _db.collection('horoscopes').doc(sign).get();
    if (doc.exists) {
      return HoroscopeModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<List<HoroscopeModel>> streamHoroscopes() {
    return _db.collection('horoscopes').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => HoroscopeModel.fromMap(doc.data()))
            .toList());
  }

  // ─── CONTENT/PDF METHODS ───────────────────────────────────────────────────

  Future<void> saveContentFile(ContentFileModel file) async {
    await _db.collection('content').doc(file.id).set(file.toMap());
  }

  Stream<List<ContentFileModel>> streamContentByCategory(String category) {
    return _db
        .collection('content')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContentFileModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteContentFile(String id) async {
    await _db.collection('content').doc(id).delete();
  }

  // ─── CONFIG METHODS ────────────────────────────────────────────────────────

  Future<String> getWhatsAppLink() async {
    var doc = await _db.collection('config').doc('whatsapp').get();
    if (doc.exists) {
      return doc.data()?['link'] ?? '';
    }
    return '';
  }

  Future<void> updateWhatsAppLink(String link) async {
    await _db.collection('config').doc('whatsapp').set({'link': link});
  }

  /// Obtiene la configuración general de la app desde `config/app`.
  Future<Map<String, dynamic>> getAppConfig() async {
    var doc = await _db.collection('config').doc('app').get();
    if (doc.exists) {
      return doc.data() ?? {};
    }
    return {};
  }

  /// Guarda la configuración general de la app en `config/app`.
  Future<void> updateAppConfig(Map<String, dynamic> config) async {
    await _db.collection('config').doc('app').set(config, SetOptions(merge: true));
  }

  // ─── TAROT METHODS ─────────────────────────────────────────────────────────

  Stream<List<TarotCardModel>> streamTarotCards() {
    return _db
        .collection('tarot_cards')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TarotCardModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveTarotCard(TarotCardModel card) async {
    await _db.collection('tarot_cards').doc(card.id).set(card.toMap());
  }

  Future<void> deleteTarotCard(String id) async {
    await _db.collection('tarot_cards').doc(id).delete();
  }

  // ─── LIMPIEZAS METHODS ─────────────────────────────────────────────────────

  Stream<List<LimpiezaModel>> streamLimpiezas() {
    return _db
        .collection('limpiezas')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LimpiezaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveLimpieza(LimpiezaModel limpieza) async {
    await _db.collection('limpiezas').doc(limpieza.id).set(limpieza.toMap());
  }

  Future<void> deleteLimpieza(String id) async {
    await _db.collection('limpiezas').doc(id).delete();
  }

  // ─── RITUALES METHODS ──────────────────────────────────────────────────────

  Stream<List<RitualModel>> streamRituales() {
    return _db
        .collection('rituales')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RitualModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveRitual(RitualModel ritual) async {
    await _db.collection('rituales').doc(ritual.id).set(ritual.toMap());
  }

  Future<void> deleteRitual(String id) async {
    await _db.collection('rituales').doc(id).delete();
  }

  // ─── PLANES METHODS ────────────────────────────────────────────────────────

  Stream<List<PlanModel>> streamPlanes() {
    return _db
        .collection('planes')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PlanModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<PlanModel>> getPlanes() async {
    final snap = await _db
        .collection('planes')
        .where('activo', isEqualTo: true)
        .orderBy('orden')
        .get();
    return snap.docs.map((doc) => PlanModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> savePlan(PlanModel plan) async {
    await _db.collection('planes').doc(plan.id).set(plan.toMap());
  }

  Future<void> deletePlan(String id) async {
    await _db.collection('planes').doc(id).delete();
  }

  Future<void> updatePlanStatus(String id, bool activo) async {
    await _db.collection('planes').doc(id).update({'activo': activo});
  }

  /// Guarda el plan seleccionado por el usuario (antes de pagar)
  Future<void> setUserPendingPlan(
    String uid,
    String planId,
    String planNombre,
    double planPrecio, {
    int? planDias,
  }) async {
    await _db.collection('user').doc(uid).update({
      'pendingPlanId': planId,
      'pendingPlanNombre': planNombre,
      'pendingPlanPrecio': planPrecio,
      'pendingPlanDias': planDias,
      'pendingApproval': true,
    });
  }
}
