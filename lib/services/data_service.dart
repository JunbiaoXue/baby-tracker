import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feeding_record.dart';
import '../models/diaper_record.dart';
import '../models/supplement_record.dart';
import '../models/sleep_record.dart';
import '../models/growth_record.dart';
import '../models/milestone_record.dart';

class DataService extends ChangeNotifier {
  static const String _storageKey = 'baby_tracker_data_v1';

  List<FeedingRecord> _feedingRecords = [];
  List<DiaperRecord> _diaperRecords = [];
  List<SupplementRecord> _supplementRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<GrowthRecord> _growthRecords = [];
  List<MilestoneRecord> _milestoneRecords = [];
  String _babyName = '宝宝';
  DateTime? _babyBirthday;

  List<FeedingRecord> get feedingRecords => _feedingRecords;
  List<DiaperRecord> get diaperRecords => _diaperRecords;
  List<SupplementRecord> get supplementRecords => _supplementRecords;
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<GrowthRecord> get growthRecords => _growthRecords;
  List<MilestoneRecord> get milestoneRecords => _milestoneRecords;
  String get babyName => _babyName;
  DateTime? get babyBirthday => _babyBirthday;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _babyName = decoded['babyName'] as String? ?? '宝宝';

          final birthday = decoded['babyBirthday'];
          if (birthday is String && birthday.isNotEmpty) {
            _babyBirthday = DateTime.tryParse(birthday);
          }

          _feedingRecords = _decodeList(
            decoded['feedingRecords'],
            FeedingRecord.fromJson,
          );
          _diaperRecords = _decodeList(
            decoded['diaperRecords'],
            DiaperRecord.fromJson,
          );
          _supplementRecords = _decodeList(
            decoded['supplementRecords'],
            SupplementRecord.fromJson,
          );
          _sleepRecords = _decodeList(
            decoded['sleepRecords'],
            SleepRecord.fromJson,
          );
          _growthRecords = _decodeList(
            decoded['growthRecords'],
            GrowthRecord.fromJson,
          );
          _milestoneRecords = _decodeList(
            decoded['milestoneRecords'],
            MilestoneRecord.fromJson,
          );
        }
      } catch (e, stackTrace) {
        debugPrint('Failed to restore persisted baby tracker data: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    notifyListeners();
  }

  List<T> _decodeList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return <T>[];

    final result = <T>[];
    for (final item in value) {
      if (item is! Map) continue;
      try {
        result.add(fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('Skipping invalid persisted record: $e');
      }
    }
    return result;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'version': 1,
      'babyName': _babyName,
      'babyBirthday': _babyBirthday?.toIso8601String(),
      'feedingRecords': _feedingRecords.map((r) => r.toJson()).toList(),
      'diaperRecords': _diaperRecords.map((r) => r.toJson()).toList(),
      'supplementRecords': _supplementRecords.map((r) => r.toJson()).toList(),
      'sleepRecords': _sleepRecords.map((r) => r.toJson()).toList(),
      'growthRecords': _growthRecords.map((r) => r.toJson()).toList(),
      'milestoneRecords': _milestoneRecords.map((r) => r.toJson()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  // ---- 宝宝信息 ----
  Future<void> setBabyInfo(String name, DateTime birthday) async {
    _babyName = name;
    _babyBirthday = birthday;
    await _persist();
    notifyListeners();
  }

  // ---- 喂奶 ----
  Future<void> addFeeding(FeedingRecord record) async {
    _feedingRecords.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteFeeding(String id) async {
    _feedingRecords.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  List<FeedingRecord> todayFeedings() {
    final now = DateTime.now();
    return _feedingRecords.where((r) =>
      r.time.year == now.year && r.time.month == now.month && r.time.day == now.day
    ).toList();
  }

  // ---- 尿布 ----
  Future<void> addDiaper(DiaperRecord record) async {
    _diaperRecords.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteDiaper(String id) async {
    _diaperRecords.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  List<DiaperRecord> todayDiapers() {
    final now = DateTime.now();
    return _diaperRecords.where((r) =>
      r.time.year == now.year && r.time.month == now.month && r.time.day == now.day
    ).toList();
  }

  // ---- 营养补充 ----
  Future<void> setSupplement(SupplementRecord record) async {
    final idx = _supplementRecords.indexWhere(
      (r) => r.date.toIso8601String().substring(0,10) == record.date.toIso8601String().substring(0,10)
    );
    if (idx >= 0) {
      _supplementRecords[idx] = record;
    } else {
      _supplementRecords.insert(0, record);
    }
    await _persist();
    notifyListeners();
  }

  SupplementRecord? todaySupplement() {
    final today = DateTime.now().toIso8601String().substring(0,10);
    try {
      return _supplementRecords.firstWhere(
        (r) => r.date.toIso8601String().substring(0,10) == today
      );
    } catch (e) {
      return null;
    }
  }

  // ---- 睡眠 ----
  Future<void> addSleep(SleepRecord record) async {
    _sleepRecords.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> updateSleep(SleepRecord record) async {
    final idx = _sleepRecords.indexWhere((r) => r.id == record.id);
    if (idx >= 0) {
      _sleepRecords[idx] = record;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteSleep(String id) async {
    _sleepRecords.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  SleepRecord? get ongoingSleep {
    try {
      return _sleepRecords.firstWhere((r) => r.isOngoing);
    } catch (e) {
      return null;
    }
  }

  // ---- 生长发育 ----
  Future<void> addGrowth(GrowthRecord record) async {
    _growthRecords.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteGrowth(String id) async {
    _growthRecords.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  // ---- 里程碑 ----
  Future<void> addMilestone(MilestoneRecord record) async {
    _milestoneRecords.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    _milestoneRecords.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  // ---- 今日统计 ----
  Map<String, dynamic> todayStats() {
    final feedings = todayFeedings();
    final diapers = todayDiapers();
    final sleeps = sleepRecords.where((s) {
      final now = DateTime.now();
      return s.startTime.year == now.year && s.startTime.month == now.month && s.startTime.day == now.day;
    }).toList();

    int totalBottleMl = 0;
    int totalBreastMinutes = 0;
    for (final f in feedings) {
      if (f.type != FeedingType.breastDirect) {
        totalBottleMl += f.bottleMl ?? 0;
      } else {
        totalBreastMinutes += f.breastMinutes ?? 0;
      }
    }

    int peeCount = diapers.where((d) => d.type == DiaperType.pee || d.type == DiaperType.both).length;
    int poopCount = diapers.where((d) => d.type == DiaperType.poop || d.type == DiaperType.both).length;

    int totalSleepMinutes = 0;
    for (final s in sleeps) {
      if (s.duration != null) {
        totalSleepMinutes += s.duration!.inMinutes;
      }
    }

    return {
      'feedingCount': feedings.length,
      'totalBottleMl': totalBottleMl,
      'totalBreastMinutes': totalBreastMinutes,
      'diaperCount': diapers.length,
      'peeCount': peeCount,
      'poopCount': poopCount,
      'totalSleepMinutes': totalSleepMinutes,
    };
  }

  // 合并时间相近的记录（10分钟内视为一组）
  // 只合并同类型记录（如：左侧+右侧母乳，或多次奶粉），不同类型不合并（如喂奶+尿布）
  List<Map<String, dynamic>> getMergedRecords() {
    // 按类型分组分别处理
    final feedingRecords = <Map<String, dynamic>>[];
    for (final f in _feedingRecords) {
      feedingRecords.add({'time': f.time, 'type': 'feeding', 'record': f});
    }
    final diaperRecords = <Map<String, dynamic>>[];
    for (final d in _diaperRecords) {
      diaperRecords.add({'time': d.time, 'type': 'diaper', 'record': d});
    }

    // 合并同类记录
    List<Map<String, dynamic>> mergeGroup(List<Map<String, dynamic>> records) {
      if (records.isEmpty) return [];
      records.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
      final merged = <Map<String, dynamic>>[];
      for (final item in records) {
        if (merged.isEmpty) {
          merged.add({'time': item['time'], 'type': item['type'], 'events': [item]});
        } else {
          final last = merged.last;
          final diff = (item['time'] as DateTime).difference(last['time'] as DateTime).inMinutes;
          if (diff <= 10) {
            (last['events'] as List).add(item);
          } else {
            merged.add({'time': item['time'], 'type': item['type'], 'events': [item]});
          }
        }
      }
      return merged;
    }

    final mergedFeeding = mergeGroup(feedingRecords);
    final mergedDiaper = mergeGroup(diaperRecords);

    // 合并两组并按时间排序
    final allMerged = [...mergedFeeding, ...mergedDiaper];
    allMerged.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return allMerged;
  }

  // 间隔时间统计
  List<Map<String, dynamic>> getIntervals(String type) {
    final records = type == 'feeding'
        ? _feedingRecords.cast<dynamic>()
        : _diaperRecords.cast<dynamic>();
    if (records.length < 2) return [];
    final times = records.map((r) => r.time as DateTime).toList()..sort();
    return [
      for (int i = 1; i < times.length; i++)
        {'from': times[i-1], 'to': times[i], 'minutes': times[i].difference(times[i-1]).inMinutes}
    ];
  }

  // 每周每日频次统计
  Map<String, dynamic> getFrequencyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dailyStats = <String, Map<String, int>>{};
    for (int i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      dailyStats['${d.month}/${d.day}'] = {'feeding': 0, 'diaper': 0};
    }
    for (final f in _feedingRecords) {
      if (f.time.isAfter(weekStart)) {
        final key = '${f.time.month}/${f.time.day}';
        if (dailyStats.containsKey(key)) {
          dailyStats[key]!['feeding'] = (dailyStats[key]!['feeding'] ?? 0) + 1;
        }
      }
    }
    for (final d in _diaperRecords) {
      if (d.time.isAfter(weekStart)) {
        final key = '${d.time.month}/${d.time.day}';
        if (dailyStats.containsKey(key)) {
          dailyStats[key]!['diaper'] = (dailyStats[key]!['diaper'] ?? 0) + 1;
        }
      }
    }
    int totalFeeding = 0, totalDiaper = 0;
    for (final stat in dailyStats.values) {
      totalFeeding += stat['feeding']!;
      totalDiaper += stat['diaper']!;
    }
    return {
      'dailyStats': dailyStats,
      'avgFeedingPerDay': (totalFeeding / 7).toStringAsFixed(1),
      'avgDiaperPerDay': (totalDiaper / 7).toStringAsFixed(1),
      'totalFeeding': totalFeeding,
      'totalDiaper': totalDiaper,
    };
  }
}
