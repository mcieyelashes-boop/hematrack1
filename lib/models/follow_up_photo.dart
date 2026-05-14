class FollowUpPhoto {
  final String id;
  final String areaId;
  final String photoPath;
  final DateTime date;
  final double areaRelativeValue;

  FollowUpPhoto({
    required this.id,
    required this.areaId,
    required this.photoPath,
    required this.date,
    required this.areaRelativeValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'areaId': areaId,
        'photoPath': photoPath,
        'date': date.toIso8601String(),
        'areaRelativeValue': areaRelativeValue,
      };

  factory FollowUpPhoto.fromJson(Map<String, dynamic> json) {
    return FollowUpPhoto(
      id: json['id'],
      areaId: json['areaId'],
      photoPath: json['photoPath'],
      date: DateTime.parse(json['date']),
      areaRelativeValue: (json['areaRelativeValue'] as num).toDouble(),
    );
  }
}
