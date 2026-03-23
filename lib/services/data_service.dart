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
  static const String _kFeeding = 'feeding_records';
  static const String _kDiaper = 'diaper_records';
  static const String _kSupplement = 'supplement_records';
  static const String _kSleep = 'sleep_records';
  static const String _kGrowth = 'growth_records';
  static const String _kMilestone = 'milestone_records';
  static const String _kBabyName = 'baby_name';
  static const String _kBabyBirthday = 'baby_birthday';

  late SharedPreferences _prefs;

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
    _prefs = await SharedPreferences.getInstance();
    await _loadAll();
  }

  Future<void> _loadAll() async {
    _feedingRecords = _loadList<FeedingRecord>(_kFeeding, FeedingRecord.fromJson);
    _diaperRecords = _loadList<DiaperRecord>(_kDiaper, DiaperRecord.fromJson);
    _supplementRecords = _loadList<SupplementRecord>(_kSupplement, SupplementRecord.fromJson);
    _sleepRecords = _loadList<SleepRecord>(_kSleep, SleepRecord.fromJson);
    _growthRecords = _loadList<GrowthRecord>(_kGrowth, GrowthRecord.fromJson);
    _milestoneRecords = _loadList<MilestoneRecord>(_kMilestone, MilestoneRecord.fromJson);
    _babyName = _prefs.getString(_kBabyName) ?? '宝宝';
    final bd = _prefs.getString(_kBabyBirthday);
    if (bd != null) _babyBirthday = DateTime.parse(bd);
    notifyListeners();
  }

  List<T> _loadList<T>(String key, T Function(Map<String,dynamic>) fromJson) {
    final str = _prefs.getString(key);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveList<T>(String key, List<T> list, Map<String,dynamic> Function(T) toJson) async {
    final str = jsonEncode(list.map((e) => toJson(e)).toList());
    await _prefs.setString(key, str);
  }

  // ---- 宝宝信息 ----
  Future<void> setBabyInfo(String name, DateTime birthday) async {
    _babyName = name;
    _babyBirthday = birthday;
    await _prefs.setString(_kBabyName, name);
    await _prefs.setString(_kBabyBirthday, birthday.toIso8601String());
    notifyListeners();
  }

  // ---- 喂奶 ----
  Future<void> addFeeding(FeedingRecord record) async {
    _feedingRecords.insert(0, record);
    await _saveList(_kFeeding, _feedingRecords, (r) => r.toJson());
    notifyListeners();
  }

  Future<void> deleteFeeding(String id) async {
    _feedingRecords.removeWhere((r) => r.id == id);
    await _saveList(_kFeeding, _feedingRecords, (r) => r.toJson());
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
    await _saveList(_kDiaper, _diaperRecords, (r) => r.toJson());
    notifyListeners();
  }

  Future<void> deleteDiaper(String id) async {
    _diaperRecords.removeWhere((r) => r.id == id);
    await _saveList(_kDiaper, _diaperRecords, (r) => r.toJson());
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
    await _saveList(_kSupplement, _supplementRecords, (r) => r.toJson());
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
    await _saveList(_kSleep, _sleepRecords, (r) => r.toJson());
    notifyListeners();
  }

  Future<void> updateSleep(SleepRecord record) async {
    final idx = _sleepRecords.indexWhere((r) => r.id == record.id);
    if (idx >= 0) {
      _sleepRecords[idx] = record;
      await _saveList(_kSleep, _sleepRecords, (r) => r.toJson());
      notifyListeners();
    }
  }

  Future<void> deleteSleep(String id) async {
    _sleepRecords.removeWhere((r) => r.id == id);
    await _saveList(_kSleep, _sleepRecords, (r) => r.toJson());
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
    await _saveList(_kGrowth, _growthRecords, (r) => r.toJson());
    notifyListeners();
  }

  Future<void> deleteGrowth(String id) async {
    _growthRecords.removeWhere((r) => r.id == id);
    await _saveList(_kGrowth, _growthRecords, (r) => r.toJson());
    notifyListeners();
  }

  // ---- 里程碑 ----
  Future<void> addMilestone(MilestoneRecord record) async {
    _milestoneRecords.insert(0, record);
    await _saveList(_kMilestone, _milestoneRecords, (r) => r.toJson());
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    _milestoneRecords.removeWhere((r) => r.id == id);
    await _saveList(_kMilestone, _milestoneRecords, (r) => r.toJson());
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
}
