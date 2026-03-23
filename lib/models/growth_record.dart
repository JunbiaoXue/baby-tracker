import 'package:uuid/uuid.dart';

class GrowthRecord {
  final String id;
  final DateTime date;
  final double? weightKg;
  final double? heightCm;
  final double? headCircumferenceCm;
  final String? note;

  GrowthRecord({
    String? id,
    required this.date,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weightKg': weightKg,
    'heightCm': heightCm,
    'headCircumferenceCm': headCircumferenceCm,
    'note': note,
  };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
    id: json['id'],
    date: DateTime.parse(json['date']),
    weightKg: json['weightKg']?.toDouble(),
    heightCm: json['heightCm']?.toDouble(),
    headCircumferenceCm: json['headCircumferenceCm']?.toDouble(),
    note: json['note'],
  );
}
