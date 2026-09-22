import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baby_record/models/diaper_record.dart';
import 'package:baby_record/models/feeding_record.dart';
import 'package:baby_record/models/growth_record.dart';
import 'package:baby_record/models/milestone_record.dart';
import 'package:baby_record/models/sleep_record.dart';
import 'package:baby_record/models/supplement_record.dart';
import 'package:baby_record/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists all tracker data across DataService instances', () async {
    final service = DataService();
    await service.init();

    final birthday = DateTime(2025, 6, 1);
    final feedingTime = DateTime(2026, 9, 22, 8, 30);
    final diaperTime = DateTime(2026, 9, 22, 9, 0);
    final sleepStart = DateTime(2026, 9, 22, 10, 0);
    final sleepEnd = DateTime(2026, 9, 22, 11, 15);
    final recordDate = DateTime(2026, 9, 22);

    await service.setBabyInfo('小宝', birthday);
    await service.addFeeding(FeedingRecord(
      id: 'feeding-1',
      time: feedingTime,
      type: FeedingType.formula,
      bottleMl: 120,
      note: 'test',
    ));
    await service.addDiaper(DiaperRecord(
      id: 'diaper-1',
      time: diaperTime,
      type: DiaperType.both,
    ));
    await service.setSupplement(SupplementRecord(
      id: 'supplement-1',
      date: recordDate,
      tookAD: true,
      tookD3: true,
      others: const ['铁'],
    ));
    await service.addSleep(SleepRecord(
      id: 'sleep-1',
      startTime: sleepStart,
      endTime: sleepEnd,
      quality: SleepQuality.good,
    ));
    await service.addGrowth(GrowthRecord(
      id: 'growth-1',
      date: recordDate,
      weightKg: 8.2,
      heightCm: 70.5,
    ));
    await service.addMilestone(MilestoneRecord(
      id: 'milestone-1',
      date: recordDate,
      title: '会翻身',
      category: 'milestone',
    ));

    final restored = DataService();
    await restored.init();

    expect(restored.babyName, '小宝');
    expect(restored.babyBirthday, birthday);
    expect(restored.feedingRecords, hasLength(1));
    expect(restored.feedingRecords.single.id, 'feeding-1');
    expect(restored.feedingRecords.single.bottleMl, 120);
    expect(restored.diaperRecords.single.id, 'diaper-1');
    expect(restored.supplementRecords.single.tookAD, isTrue);
    expect(restored.sleepRecords.single.endTime, sleepEnd);
    expect(restored.growthRecords.single.weightKg, 8.2);
    expect(restored.milestoneRecords.single.title, '会翻身');
  });

  test('persists updates and deletions', () async {
    final service = DataService();
    await service.init();

    final start = DateTime(2026, 9, 22, 10, 0);
    await service.addSleep(SleepRecord(
      id: 'sleep-1',
      startTime: start,
    ));
    await service.updateSleep(SleepRecord(
      id: 'sleep-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 45)),
    ));

    await service.addFeeding(FeedingRecord(
      id: 'feeding-1',
      time: DateTime(2026, 9, 22, 8, 0),
      type: FeedingType.formula,
      bottleMl: 90,
    ));
    await service.deleteFeeding('feeding-1');

    final restored = DataService();
    await restored.init();

    expect(restored.feedingRecords, isEmpty);
    expect(restored.sleepRecords, hasLength(1));
    expect(restored.sleepRecords.single.duration, const Duration(minutes: 45));
  });

  test('ignores corrupt persisted data instead of crashing init', () async {
    SharedPreferences.setMockInitialValues({
      'baby_tracker_data_v1': '{not valid json',
    });

    final service = DataService();
    await service.init();

    expect(service.babyName, '宝宝');
    expect(service.feedingRecords, isEmpty);
    expect(service.diaperRecords, isEmpty);
  });
}
