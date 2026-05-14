class HemangiomaArea {
  final String id;
  final String childId;
  final String bodyLocation;
  final String baselinePhotoPath;
  final DateTime baselineDate;
  final double baselineAreaValue;
  final String notes;

  HemangiomaArea({
    required this.id,
    required this.childId,
    required this.bodyLocation,
    required this.baselinePhotoPath,
    required this.baselineDate,
    this.baselineAreaValue = 0,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'bodyLocation': bodyLocation,
        'baselinePhotoPath': baselinePhotoPath,
        'baselineDate': baselineDate.toIso8601String(),
        'baselineAreaValue': baselineAreaValue,
        'notes': notes,
      };

  factory HemangiomaArea.fromJson(Map<String, dynamic> json) {
    return HemangiomaArea(
      id: json['id'],
      childId: json['childId'],
      bodyLocation: json['bodyLocation'],
      baselinePhotoPath: json['baselinePhotoPath'],
      baselineDate: DateTime.parse(json['baselineDate']),
      baselineAreaValue: (json['baselineAreaValue'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] ?? '',
    );
  }
}
