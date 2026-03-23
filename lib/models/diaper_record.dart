import 'package:uuid/uuid.dart';

enum DiaperType { pee, poop, both }

class DiaperRecord {
  final String id;
  final DateTime time;
  final DiaperType type;
  final String? poopColor;
  final String? note;

  DiaperRecord({
    String? id,
    required this.time,
    required this.type,
    this.poopColor,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time.toIso8601String(),
    'type': type.index,
    'poopColor': poopColor,
    'note': note,
  };

  factory DiaperRecord.fromJson(Map<String, dynamic> json) => DiaperRecord(
    id: json['id'],
    time: DateTime.parse(json['time']),
    type: DiaperType.values[json['type']],
    poopColor: json['poopColor'],
    note: json['note'],
  );

  String get typeName {
    switch (type) {
      case DiaperType.pee: return '小便';
      case DiaperType.poop: return '大便';
      case DiaperType.both: return '大小便';
    }
  }
}
