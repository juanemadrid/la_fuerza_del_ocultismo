import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';
import '../models/content_file_model.dart';
import '../models/tarot_card_model.dart';
import '../models/limpieza_model.dart';
import '../models/ritual_model.dart';
import '../models/plan_model.dart';

class DatabaseService {
  // ─── SINGLETON CON CACHÉ INTELIGENTE ──────────────────────────────────────
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── CACHÉ EN MEMORIA Y TIEMPOS DE EXPIRACIÓN ─────────────────────────────
  String? _cachedWhatsAppLink;
  DateTime? _whatsAppCacheTime;

  Map<String, dynamic>? _cachedAppConfig;
  DateTime? _appConfigCacheTime;

  final Map<String, HoroscopeModel> _cachedHoroscopes = {};
  final Map<String, DateTime> _horoscopeCacheTimes = {};

  List<TarotCardModel>? _cachedTarotCards;
  DateTime? _tarotCardsCacheTime;
  Stream<List<TarotCardModel>>? _tarotStream;

  List<LimpiezaModel>? _cachedLimpiezas;
  DateTime? _limpiezasCacheTime;
  Stream<List<LimpiezaModel>>? _limpiezasStream;

  List<RitualModel>? _cachedRituales;
  DateTime? _ritualesCacheTime;
  Stream<List<RitualModel>>? _ritualesStream;

  List<PlanModel>? _cachedPlanes;
  DateTime? _planesCacheTime;
  Stream<List<PlanModel>>? _planesStream;

  // Getters para acceso síncrono rápido a caché
  String? get cachedWhatsAppLink => _cachedWhatsAppLink;
  Map<String, dynamic>? get cachedAppConfig => _cachedAppConfig;
  List<TarotCardModel>? get cachedTarotCards => _cachedTarotCards;
  List<LimpiezaModel>? get cachedLimpiezas => _cachedLimpiezas;
  List<RitualModel>? get cachedRituales => _cachedRituales;
  List<PlanModel>? get cachedPlanes => _cachedPlanes;

  /// Limpia manualmente todas las cachés locales si se requiere forzar recarga completa
  void clearCache() {
    _cachedWhatsAppLink = null;
    _whatsAppCacheTime = null;
    _cachedAppConfig = null;
    _appConfigCacheTime = null;
    _cachedHoroscopes.clear();
    _horoscopeCacheTimes.clear();
    _cachedTarotCards = null;
    _tarotCardsCacheTime = null;
    _tarotStream = null;
    _cachedLimpiezas = null;
    _limpiezasCacheTime = null;
    _limpiezasStream = null;
    _cachedRituales = null;
    _ritualesCacheTime = null;
    _ritualesStream = null;
    _cachedPlanes = null;
    _planesCacheTime = null;
    _planesStream = null;
  }

  // ─── USER METHODS ──────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _db.collection('user').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('user').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isSubscribed'] == true && data['subscriptionExpiry'] != null) {
        final expiry = (data['subscriptionExpiry'] as dynamic).toDate() as DateTime;
        if (expiry.isBefore(DateTime.now())) {
          // Actualización asíncrona de fondo sin bloquear el inicio de sesión
          _db.collection('user').doc(uid).update({'isSubscribed': false});
          data['isSubscribed'] = false;
        }
      }
      return UserModel.fromMap(data, doc.id);
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

  // ─── HOROSCOPE METHODS (OPTIMIZADOS CON CACHÉ) ─────────────────────────────

  Future<void> updateHoroscope(HoroscopeModel horoscope) async {
    await _db
        .collection('horoscopes')
        .doc(horoscope.sign)
        .set(horoscope.toMap());
    _cachedHoroscopes[horoscope.sign] = horoscope;
    _horoscopeCacheTimes[horoscope.sign] = DateTime.now();
  }

  Future<HoroscopeModel?> getHoroscope(String sign, {bool forceRefresh = false}) async {
    // Si ya fue consultado en la sesión actual y tiene menos de 4 horas, retornar de memoria
    if (!forceRefresh &&
        _cachedHoroscopes.containsKey(sign) &&
        _horoscopeCacheTimes.containsKey(sign) &&
        DateTime.now().difference(_horoscopeCacheTimes[sign]!).inHours < 4) {
      return _cachedHoroscopes[sign];
    }

    try {
      var doc = await _db.collection('horoscopes').doc(sign).get();
      if (doc.exists) {
        final horoscope = HoroscopeModel.fromMap(doc.data()!);
        _cachedHoroscopes[sign] = horoscope;
        _horoscopeCacheTimes[sign] = DateTime.now();
        return horoscope;
      }
    } catch (_) {}

    return _cachedHoroscopes[sign];
  }

  Stream<List<HoroscopeModel>> streamHoroscopes() {
    return _db.collection('horoscopes').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HoroscopeModel.fromMap(doc.data()))
          .toList();
      for (var h in list) {
        _cachedHoroscopes[h.sign] = h;
        _horoscopeCacheTimes[h.sign] = DateTime.now();
      }
      return list;
    });
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

  // ─── CONFIG METHODS (OPTIMIZADOS CON CACHÉ DE MEMORIA Y LOCAL) ────────────

  /// Obtiene el enlace de WhatsApp con caché local (memoria + SharedPreferences).
  /// Evita realizar lecturas repetitivas a Firestore en cada renderizado de la UI.
  Future<String> getWhatsAppLink({bool forceRefresh = false}) async {
    // 1. Memoria rápida si tiene menos de 2 horas
    if (!forceRefresh &&
        _cachedWhatsAppLink != null &&
        _cachedWhatsAppLink!.isNotEmpty &&
        _whatsAppCacheTime != null &&
        DateTime.now().difference(_whatsAppCacheTime!).inHours < 2) {
      return _cachedWhatsAppLink!;
    }

    // 2. Persistencia en SharedPreferences si aún es válida (< 24 horas)
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('cached_whatsapp_link');
        final storedTime = prefs.getInt('cached_whatsapp_link_time');
        if (stored != null && stored.isNotEmpty && storedTime != null) {
          final diff = DateTime.now().millisecondsSinceEpoch - storedTime;
          if (diff < const Duration(hours: 24).inMilliseconds) {
            _cachedWhatsAppLink = stored;
            _whatsAppCacheTime = DateTime.fromMillisecondsSinceEpoch(storedTime);
            return stored;
          }
        }
      } catch (_) {}
    }

    // 3. Consulta a Firestore (solo si no hay caché o expiró)
    try {
      var doc = await _db.collection('config').doc('whatsapp').get();
      if (doc.exists) {
        final link = doc.data()?['link']?.toString() ?? '';
        _cachedWhatsAppLink = link;
        _whatsAppCacheTime = DateTime.now();

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_whatsapp_link', link);
          await prefs.setInt('cached_whatsapp_link_time', DateTime.now().millisecondsSinceEpoch);
        } catch (_) {}

        return link;
      }
    } catch (_) {}

    return _cachedWhatsAppLink ?? '';
  }

  Future<void> updateWhatsAppLink(String link) async {
    await _db.collection('config').doc('whatsapp').set({'link': link});
    _cachedWhatsAppLink = link;
    _whatsAppCacheTime = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_whatsapp_link', link);
      await prefs.setInt('cached_whatsapp_link_time', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Marca que el usuario ya usó su horóscopo gratis este mes.
  /// Guarda el mes actual en formato "YYYY-MM" en el documento del usuario.
  Future<void> markFreeHoroscopeUsed(String uid) async {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await _db.collection('user').doc(uid).update({
      'lastFreeHoroscopeMonth': currentMonth,
    });
  }

  /// Registra las cartas de tarot gratuitas usadas este mes.
  /// [cardsUsed] es la cantidad de cartas que se acaban de usar en esta lectura.
  Future<void> markFreeTarotCardsUsed(String uid, int cardsUsed) async {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final doc = await _db.collection('user').doc(uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final storedMonth = data['freeTarotMonth'] as String?;
    final storedCount = (data['freeTarotCardsUsed'] as int?) ?? 0;

    // Si es un mes diferente, reiniciar el contador
    final newCount = storedMonth == currentMonth ? storedCount + cardsUsed : cardsUsed;

    await _db.collection('user').doc(uid).update({
      'freeTarotMonth': currentMonth,
      'freeTarotCardsUsed': newCount,
    });
  }

  /// Obtiene la configuración general de la app desde `config/app` con caché.
  Future<Map<String, dynamic>> getAppConfig({bool forceRefresh = false}) async {
    // 1. Memoria si tiene menos de 2 horas
    if (!forceRefresh &&
        _cachedAppConfig != null &&
        _appConfigCacheTime != null &&
        DateTime.now().difference(_appConfigCacheTime!).inHours < 2) {
      return _cachedAppConfig!;
    }

    // 2. Persistencia en SharedPreferences si tiene menos de 24 horas
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = prefs.getString('cached_app_config');
        final storedTime = prefs.getInt('cached_app_config_time');
        if (jsonStr != null && jsonStr.isNotEmpty && storedTime != null) {
          final diff = DateTime.now().millisecondsSinceEpoch - storedTime;
          if (diff < const Duration(hours: 24).inMilliseconds) {
            final decoded = json.decode(jsonStr) as Map<String, dynamic>;
            _cachedAppConfig = decoded;
            _appConfigCacheTime = DateTime.fromMillisecondsSinceEpoch(storedTime);
            return decoded;
          }
        }
      } catch (_) {}
    }

    // 3. Consulta a Firestore
    try {
      var doc = await _db.collection('config').doc('app').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _cachedAppConfig = data;
        _appConfigCacheTime = DateTime.now();

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_app_config', json.encode(data));
          await prefs.setInt('cached_app_config_time', DateTime.now().millisecondsSinceEpoch);
        } catch (_) {}

        return data;
      }
    } catch (_) {}

    return _cachedAppConfig ?? {};
  }

  /// Guarda la configuración general de la app en `config/app` y actualiza la caché.
  Future<void> updateAppConfig(Map<String, dynamic> config) async {
    await _db.collection('config').doc('app').set(config, SetOptions(merge: true));
    _cachedAppConfig = config;
    _appConfigCacheTime = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_app_config', json.encode(config));
      await prefs.setInt('cached_app_config_time', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  // ─── TAROT METHODS (COMPARTIDO Y CON CACHÉ) ────────────────────────────────

  Stream<List<TarotCardModel>> streamTarotCards() {
    _tarotStream ??= _db
        .collection('tarot_cards')
        .orderBy('orden')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => TarotCardModel.fromMap(doc.data(), doc.id))
              .toList();
          _cachedTarotCards = list;
          _tarotCardsCacheTime = DateTime.now();
          return list;
        })
        .asBroadcastStream();
    return _tarotStream!;
  }

  Future<List<TarotCardModel>> getTarotCards({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedTarotCards != null &&
        _cachedTarotCards!.isNotEmpty &&
        _tarotCardsCacheTime != null &&
        DateTime.now().difference(_tarotCardsCacheTime!).inHours < 2) {
      return _cachedTarotCards!;
    }
    try {
      final snap = await _db.collection('tarot_cards').orderBy('orden').get();
      _cachedTarotCards = snap.docs
          .map((doc) => TarotCardModel.fromMap(doc.data(), doc.id))
          .toList();
      _tarotCardsCacheTime = DateTime.now();
      return _cachedTarotCards!;
    } catch (_) {}
    return _cachedTarotCards ?? [];
  }

  Future<void> saveTarotCard(TarotCardModel card) async {
    await _db.collection('tarot_cards').doc(card.id).set(card.toMap());
    _cachedTarotCards = null;
    _tarotCardsCacheTime = null;
  }

  Future<void> deleteTarotCard(String id) async {
    await _db.collection('tarot_cards').doc(id).delete();
    _cachedTarotCards = null;
    _tarotCardsCacheTime = null;
  }

  // ─── LIMPIEZAS METHODS (COMPARTIDO Y CON CACHÉ) ────────────────────────────

  Stream<List<LimpiezaModel>> streamLimpiezas() {
    _limpiezasStream ??= _db
        .collection('limpiezas')
        .orderBy('orden')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => LimpiezaModel.fromMap(doc.data(), doc.id))
              .toList();
          _cachedLimpiezas = list;
          _limpiezasCacheTime = DateTime.now();
          return list;
        })
        .asBroadcastStream();
    return _limpiezasStream!;
  }

  Future<List<LimpiezaModel>> getLimpiezas({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedLimpiezas != null &&
        _cachedLimpiezas!.isNotEmpty &&
        _limpiezasCacheTime != null &&
        DateTime.now().difference(_limpiezasCacheTime!).inHours < 2) {
      return _cachedLimpiezas!;
    }
    try {
      final snap = await _db.collection('limpiezas').orderBy('orden').get();
      _cachedLimpiezas = snap.docs
          .map((doc) => LimpiezaModel.fromMap(doc.data(), doc.id))
          .toList();
      _limpiezasCacheTime = DateTime.now();
      return _cachedLimpiezas!;
    } catch (_) {}
    return _cachedLimpiezas ?? [];
  }

  Future<void> saveLimpieza(LimpiezaModel limpieza) async {
    await _db.collection('limpiezas').doc(limpieza.id).set(limpieza.toMap());
    _cachedLimpiezas = null;
    _limpiezasCacheTime = null;
  }

  Future<void> deleteLimpieza(String id) async {
    await _db.collection('limpiezas').doc(id).delete();
    _cachedLimpiezas = null;
    _limpiezasCacheTime = null;
  }

  // ─── RITUALES METHODS (COMPARTIDO Y CON CACHÉ) ─────────────────────────────

  Stream<List<RitualModel>> streamRituales() {
    _ritualesStream ??= _db
        .collection('rituales')
        .orderBy('orden')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => RitualModel.fromMap(doc.data(), doc.id))
              .toList();
          _cachedRituales = list;
          _ritualesCacheTime = DateTime.now();
          return list;
        })
        .asBroadcastStream();
    return _ritualesStream!;
  }

  Future<List<RitualModel>> getRituales({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedRituales != null &&
        _cachedRituales!.isNotEmpty &&
        _ritualesCacheTime != null &&
        DateTime.now().difference(_ritualesCacheTime!).inHours < 2) {
      return _cachedRituales!;
    }
    try {
      final snap = await _db.collection('rituales').orderBy('orden').get();
      _cachedRituales = snap.docs
          .map((doc) => RitualModel.fromMap(doc.data(), doc.id))
          .toList();
      _ritualesCacheTime = DateTime.now();
      return _cachedRituales!;
    } catch (_) {}
    return _cachedRituales ?? [];
  }

  Future<void> saveRitual(RitualModel ritual) async {
    await _db.collection('rituales').doc(ritual.id).set(ritual.toMap());
    _cachedRituales = null;
    _ritualesCacheTime = null;
  }

  Future<void> deleteRitual(String id) async {
    await _db.collection('rituales').doc(id).delete();
    _cachedRituales = null;
    _ritualesCacheTime = null;
  }

  // ─── PLANES METHODS (COMPARTIDO Y CON CACHÉ) ───────────────────────────────

  Stream<List<PlanModel>> streamPlanes() {
    _planesStream ??= _db
        .collection('planes')
        .orderBy('orden')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => PlanModel.fromMap(doc.data(), doc.id))
              .toList();
          _cachedPlanes = list;
          _planesCacheTime = DateTime.now();
          return list;
        })
        .asBroadcastStream();
    return _planesStream!;
  }

  Future<List<PlanModel>> getPlanes({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedPlanes != null &&
        _cachedPlanes!.isNotEmpty &&
        _planesCacheTime != null &&
        DateTime.now().difference(_planesCacheTime!).inHours < 1) {
      return _cachedPlanes!;
    }
    try {
      final snap = await _db
          .collection('planes')
          .where('activo', isEqualTo: true)
          .orderBy('orden')
          .get();
      final list = snap.docs.map((doc) => PlanModel.fromMap(doc.data(), doc.id)).toList();
      _cachedPlanes = list;
      _planesCacheTime = DateTime.now();
      return list;
    } catch (_) {}
    return _cachedPlanes ?? [];
  }

  Future<void> savePlan(PlanModel plan) async {
    await _db.collection('planes').doc(plan.id).set(plan.toMap());
    _cachedPlanes = null;
    _planesCacheTime = null;
  }

  Future<void> deletePlan(String id) async {
    await _db.collection('planes').doc(id).delete();
    _cachedPlanes = null;
    _planesCacheTime = null;
  }

  Future<void> updatePlanStatus(String id, bool activo) async {
    await _db.collection('planes').doc(id).update({'activo': activo});
    _cachedPlanes = null;
    _planesCacheTime = null;
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
