import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';
import '../models/content_file_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER METHODS
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<UserModel>> streamUsers() {
    return _db.collection('users').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateUserSubscription(String uid, bool isSubscribed) async {
    await _db
        .collection('users')
        .doc(uid)
        .update({'isSubscribed': isSubscribed});
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String email,
    required String zodiacSign,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      'zodiacSign': zodiacSign,
    });
  }

  Future<void> updateUserZodiacSign(String uid, String zodiacSign) async {
    await _db.collection('users').doc(uid).update({'zodiacSign': zodiacSign});
  }

  // HOROSCOPE METHODS
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
    return _db.collection('horoscopes').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => HoroscopeModel.fromMap(doc.data()))
        .toList());
  }

  // CONTENT/PDF METHODS
  Future<void> saveContentFile(ContentFileModel file) async {
    await _db.collection('content').doc(file.id).set(file.toMap());
  }

  Stream<List<ContentFileModel>> streamContentByCategory(String category) {
    return _db
        .collection('content')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContentFileModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteContentFile(String id) async {
    await _db.collection('content').doc(id).delete();
  }

  // CONFIG METHODS
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
}
