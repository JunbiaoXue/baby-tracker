import 'package:flutter/foundation.dart';
import '../models/feeding_record.dart';
import '../models/diaper_record.dart';
import '../models/supplement_record.dart';
import '../models/sleep_record.dart';
import '../models/growth_record.dart';
import '../models/milestone_record.dart';

class DataService extends ChangeNotifier {
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
    // No persistence - using in-memory storage
    // Data will reset when app restarts
    notifyListeners();
  }

  // ---- 宝宝信息 ----
  Future<void> setBabyInfo(String name, DateTime birthday) async {
    _babyName = name;
    _babyBirthday = birthday;
    notifyListeners();
  }

  // ---- 喂奶 ----
  Future<void> addFeeding(FeedingRecord record) async {
    _feedingRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteFeeding(String id) async {
    _feedingRecords.removeWhere((r) => r.id == id);
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
    notifyListeners();
  }

  Future<void> deleteDiaper(String id) async {
    _diaperRecords.removeWhere((r) => r.id == id);
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
    notifyListeners();
  }

  Future<void> updateSleep(SleepRecord record) async {
    final idx = _sleepRecords.indexWhere((r) => r.id == record.id);
    if (idx >= 0) {
      _sleepRecords[idx] = record;
      notifyListeners();
    }
  }

  Future<void> deleteSleep(String id) async {
    _sleepRecords.removeWhere((r) => r.id == id);
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
    notifyListeners();
  }

  Future<void> deleteGrowth(String id) async {
    _growthRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---- 里程碑 ----
  Future<void> addMilestone(MilestoneRecord record) async {
    _milestoneRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    _milestoneRecords.removeWhere((r) => r.id == id);
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
  List<Map<String, dynamic>> getMergedRecords() {
    final allRecords = <Map<String, dynamic>>[];
    for (final f in _feedingRecords) {
      allRecords.add({'time': f.time, 'type': 'feeding', 'record': f});
    }
    for (final d in _diaperRecords) {
      allRecords.add({'time': d.time, 'type': 'diaper', 'record': d});
    }
    allRecords.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    
    final merged = <Map<String, dynamic>>[];
    for (final item in allRecords) {
      if (merged.isEmpty) {
        merged.add(item);
      } else {
        final last = merged.last;
        final diff = (item['time'] as DateTime).difference(last['time'] as DateTime).inMinutes;
        if (diff <= 10) {
          if (last['events'] == null) last['events'] = [last];
          (last['events'] as List).add(item);
        } else {
          merged.add(item);
        }
      }
    }
    return merged;
  }

  // 间隔时间统计
  List<Map<String, dynamic>> getIntervals(String type) {
    final records = type == 'feeding' ? _feedingRecords : _diaperRecords;
    if (records.length < 2) return [];
    final times = records.map((r) => r.time).toList()..sort();
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
        if (dailyStats.containsKey(key)) dailyStats[key]!['feeding']++;
      }
    }
    for (final d in _diaperRecords) {
      if (d.time.isAfter(weekStart)) {
        final key = '${d.time.month}/${d.time.day}';
        if (dailyStats.containsKey(key)) dailyStats[key]!['diaper']++;
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
