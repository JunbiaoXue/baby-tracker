import 'package:uuid/uuid.dart';

class SupplementRecord {
  final String id;
  final DateTime date; // 只记录日期，简化
  final bool tookAD;
  final bool tookD3;
  final List<String> others; // 其他补充剂

  SupplementRecord({
    String? id,
    required this.date,
    this.tookAD = false,
    this.tookD3 = false,
    List<String>? others,
  }) : id = id ?? const Uuid().v4(),
       others = others ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String().substring(0, 10),
    'tookAD': tookAD,
    'tookD3': tookD3,
    'others': others,
  };

  factory SupplementRecord.fromJson(Map<String, dynamic> json) => SupplementRecord(
    id: json['id'],
    date: DateTime.parse(json['date']),
    tookAD: json['tookAD'] ?? false,
    tookD3: json['tookD3'] ?? false,
    others: List<String>.from(json['others'] ?? []),
  );
}
