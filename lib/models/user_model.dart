class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isSubscribed;
  final String zodiacSign;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.isSubscribed = false,
    this.zodiacSign = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isSubscribed: map['isSubscribed'] ?? false,
      zodiacSign: map['zodiacSign'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isSubscribed': isSubscribed,
      'zodiacSign': zodiacSign,
    };
  }
}
