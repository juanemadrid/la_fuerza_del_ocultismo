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

  /// Mes en que el usuario usó su horóscopo gratis. Formato "YYYY-MM" (ej. "2026-06").
  final String? lastFreeHoroscopeMonth;

  /// Mes en que se contabilizaron las cartas de tarot gratis. Formato "YYYY-MM".
  final String? freeTarotMonth;

  /// Número de cartas de tarot usadas en el mes actual (plan gratis: máx 2).
  final int freeTarotCardsUsed;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.isSubscribed = false,
    this.zodiacSign = '',
    this.subscriptionExpiry,
    this.pendingApproval = false,
    this.pendingPlanId,
    this.pendingPlanNombre,
    this.pendingPlanPrecio,
    this.pendingPlanDias,
    this.birthDate = '',
    this.lastFreeHoroscopeMonth,
    this.freeTarotMonth,
    this.freeTarotCardsUsed = 0,
  });

  // Verifica si la membresía está activa en este momento
  bool get isMembershipActive {
    if (!isSubscribed) return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  /// Retorna true si el usuario (plan gratis) puede consultar el horóscopo este mes.
  bool get canUseHoroscopeThisMonth {
    if (isMembershipActive) return true; // premium siempre puede
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return lastFreeHoroscopeMonth != currentMonth;
  }

  /// Cartas de tarot disponibles este mes para plan gratis (máx 2).
  int get freeTarotCardsAvailable {
    if (isMembershipActive) return 999; // premium ilimitado
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (freeTarotMonth != currentMonth) return 2; // nuevo mes, reinicia
    return (2 - freeTarotCardsUsed).clamp(0, 2);
  }

  /// Días restantes de membresía
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
      pendingApproval: map['pendingApproval'] ?? false,
      pendingPlanId: map['pendingPlanId'],
      pendingPlanNombre: map['pendingPlanNombre'],
      pendingPlanPrecio: map['pendingPlanPrecio'] != null
          ? (map['pendingPlanPrecio'] as num).toDouble()
          : null,
      pendingPlanDias: map['pendingPlanDias'],
      birthDate: map['birthDate'] ?? '',
      lastFreeHoroscopeMonth: map['lastFreeHoroscopeMonth'],
      freeTarotMonth: map['freeTarotMonth'],
      freeTarotCardsUsed: map['freeTarotCardsUsed'] ?? 0,
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
      'lastFreeHoroscopeMonth': lastFreeHoroscopeMonth,
      'freeTarotMonth': freeTarotMonth,
      'freeTarotCardsUsed': freeTarotCardsUsed,
    };
  }
}
