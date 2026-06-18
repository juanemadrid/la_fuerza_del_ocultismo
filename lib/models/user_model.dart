class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isSubscribed;
  final String zodiacSign;
  final DateTime? subscriptionExpiry;
  final bool pendingApproval;
  final String? pendingPlanId;
  final String? pendingPlanNombre;
  final double? pendingPlanPrecio;
  final int? pendingPlanDias;
  final String birthDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.isSubscribed = false,
    this.zodiacSign = '',
    this.subscriptionExpiry,
    this.pendingApproval = true,
    this.pendingPlanId,
    this.pendingPlanNombre,
    this.pendingPlanPrecio,
    this.pendingPlanDias,
    this.birthDate = '',
  });

  // Verifica si la membresía está activa en este momento
  bool get isMembershipActive {
    if (!isSubscribed) return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  // Días restantes de membresía
  int get daysRemaining {
    if (subscriptionExpiry == null) return 0;
    final diff = subscriptionExpiry!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isSubscribed: map['isSubscribed'] ?? false,
      zodiacSign: map['zodiacSign'] ?? '',
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? (map['subscriptionExpiry'] as dynamic).toDate()
          : null,
      pendingApproval: map['pendingApproval'] ?? true,
      pendingPlanId: map['pendingPlanId'],
      pendingPlanNombre: map['pendingPlanNombre'],
      pendingPlanPrecio: map['pendingPlanPrecio'] != null
          ? (map['pendingPlanPrecio'] as num).toDouble()
          : null,
      pendingPlanDias: map['pendingPlanDias'],
      birthDate: map['birthDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isSubscribed': isSubscribed,
      'zodiacSign': zodiacSign,
      'subscriptionExpiry': subscriptionExpiry,
      'pendingApproval': pendingApproval,
      'pendingPlanId': pendingPlanId,
      'pendingPlanNombre': pendingPlanNombre,
      'pendingPlanPrecio': pendingPlanPrecio,
      'pendingPlanDias': pendingPlanDias,
      'birthDate': birthDate,
    };
  }
}
