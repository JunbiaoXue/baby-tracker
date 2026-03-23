import 'package:uuid/uuid.dart';

enum SleepQuality { good, normal, crying }

class SleepRecord {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SleepQuality? quality;
  final String? note;

  SleepRecord({
    String? id,
    required this.startTime,
    this.endTime,
    this.quality,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'quality': quality?.index,
    'note': note,
  };

  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    quality: json['quality'] != null ? SleepQuality.values[json['quality']] : null,
    note: json['note'],
  );

  bool get isOngoing => endTime == null;

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  String get durationStr {
    final d = duration;
    if (d == null) return '进行中';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '${h}小时${m}分钟' : '${m}分钟';
  }
}
