class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final DateTime createdAt;

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Usia dalam format "X bulan" atau "X tahun Y bulan".
  String get ageString {
    final now = DateTime.now();
    int months =
        (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    if (months < 1) return 'Kurang dari 1 bulan';
    if (months < 12) return '$months bulan';
    return '${months ~/ 12} tahun ${months % 12} bulan';
  }
}
