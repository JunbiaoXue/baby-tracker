import 'package:uuid/uuid.dart';

enum FeedingType { breastDirect, breastBottle, formula }

class FeedingRecord {
  final String id;
  final DateTime time;
  final FeedingType type;
  final int? breastMinutes; // 母乳亲喂时长（分钟）
  final int? bottleMl;      // 瓶喂 ml
  final String? note;

  FeedingRecord({
    String? id,
    required this.time,
    required this.type,
    this.breastMinutes,
    this.bottleMl,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time.toIso8601String(),
    'type': type.index,
    'breastMinutes': breastMinutes,
    'bottleMl': bottleMl,
    'note': note,
  };

  factory FeedingRecord.fromJson(Map<String, dynamic> json) => FeedingRecord(
    id: json['id'],
    time: DateTime.parse(json['time']),
    type: FeedingType.values[json['type']],
    breastMinutes: json['breastMinutes'],
    bottleMl: json['bottleMl'],
    note: json['note'],
  );

  String get typeName {
    switch (type) {
      case FeedingType.breastDirect: return '母乳亲喂';
      case FeedingType.breastBottle: return '母乳瓶喂';
      case FeedingType.formula: return '奶粉';
    }
  }

  String get displayAmount {
    if (type == FeedingType.breastDirect) {
      return '${breastMinutes ?? 0} 分钟';
    }
    return '${bottleMl ?? 0} ml';
  }
}
