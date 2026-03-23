import 'package:uuid/uuid.dart';

class MilestoneRecord {
  final String id;
  final DateTime date;
  final String title;
  final String? note;
  final String category; // 'milestone' | 'hospital' | 'vaccine'

  MilestoneRecord({
    String? id,
    required this.date,
    required this.title,
    this.note,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'note': note,
    'category': category,
  };

  factory MilestoneRecord.fromJson(Map<String, dynamic> json) => MilestoneRecord(
    id: json['id'],
    date: DateTime.parse(json['date']),
    title: json['title'],
    note: json['note'],
    category: json['category'],
  );
}
