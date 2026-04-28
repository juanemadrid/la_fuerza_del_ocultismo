class HoroscopeModel {
  final String sign;
  final String prediction;
  final DateTime lastUpdated;

  HoroscopeModel({
    required this.sign,
    required this.prediction,
    required this.lastUpdated,
  });

  factory HoroscopeModel.fromMap(Map<String, dynamic> map) {
    return HoroscopeModel(
      sign: map['sign'] ?? '',
      prediction: map['prediction'] ?? '',
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sign': sign,
      'prediction': prediction,
      'lastUpdated': lastUpdated,
    };
  }
}
