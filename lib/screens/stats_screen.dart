import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatSleep(int minutes, L10nService l10n) {
    if (minutes == 0) return '0${l10n.t('minutes')}';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hk = l10n.t('hours');
    final mk = l10n.t('minutes');
    return h > 0 ? '${h}$hk${m}$mk' : '${m}$mk';
  }

  List<Map> _getWeekData(DataService ds, String type, L10nService l10n) {
    final now = DateTime.now();
    final result = <Map>[];
    final weekdays = [
      l10n.t('mon'), l10n.t('tue'), l10n.t('wed'),
      l10n.t('thu'), l10n.t('fri'), l10n.t('sat'), l10n.t('sun'),
    ];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      int count = 0;
      if (type == 'feeding') {
        count = ds.feedingRecords.where((r) => r.time.year == d.year && r.time.month == d.month && r.time.day == d.day).length;
      } else {
        count = ds.diaperRecords.where((r) => r.time.year == d.year && r.time.month == d.month && r.time.day == d.day).length;
      }
      result.add({'label': weekdays[d.weekday % 7], 'count': count, 'date': d});
    }
    return result;
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final l10n = context.watch<L10nService>();
    final merged = ds.getMergedRecords();
    final feedingIntervals = ds.getIntervals('feeding');
    final diaperIntervals = ds.getIntervals('diaper');
    final freqStats = ds.getFrequencyStats();
    final stats = ds.todayStats();
    final weekFeedings = _getWeekData(ds, 'feeding', l10n);
    final weekDiapers = _getWeekData(ds, 'diaper', l10n);
    String ls(String k) => l10n.t(k);

    final feedingCount = stats['feedingCount'] ?? 0;
    final totalBottleMl = stats['totalBottleMl'] ?? 0;
    final diaperCount = stats['diaperCount'] ?? 0;
    final peeCount = stats['peeCount'] ?? 0;
    final poopCount = stats['poopCount'] ?? 0;
    final totalSleepMinutes = stats['totalSleepMinutes'] ?? 0;
    final totalBreastMinutes = stats['totalBreastMinutes'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(ls('stats_title')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 今日概况
          Text(ls('today_overview'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard(ls('feeding_times'), '$feedingCount${ls('times2')}', Icons.local_drink, Colors.blue),
                      _statCard(ls('total_milk'), '${totalBottleMl}ml', Icons.water_drop, Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(ls('diaper_count'), '$diaperCount${ls('times2')}', Icons.baby_changing_station, Colors.orange),
                      _statCard(ls('diaper_detail'), '$peeCount/$poopCount', Icons.show_chart, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(ls('sleep_duration2'), _formatSleep(totalSleepMinutes, l10n), Icons.bedtime, Colors.purple),
                      _statCard(ls('breast_duration'), '$totalBreastMinutes${ls('minutes')}', Icons.child_care, Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 合并事件说明
          if (merged.isNotEmpty) ...[
            Text(ls('merged_events'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${ls('merge_hint')}: 10${ls('minutes')}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: merged.take(10).map((item) {
                    final time = item['time'] as DateTime;
                    final type = item['type'] as String;
                    final events = item['events'] as List?;
                    final count = events != null ? events.length + 1 : 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(type == 'feeding' ? Icons.local_drink : Icons.baby_changing_station,
                              color: type == 'feeding' ? Colors.blue : Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                          const SizedBox(width: 8),
                          Text('$count${ls('times2')}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 喂奶间隔统计
          if (feedingIntervals.isNotEmpty) ...[
            Text(ls('feeding_interval'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statCard(ls('avg_interval'),
                          _formatInterval(feedingIntervals.isEmpty ? 0 :
                            feedingIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a + b) ~/ feedingIntervals.length, l10n),
                          Icons.timelapse, Colors.blue),
                        _statCard(ls('min_interval'),
                          _formatInterval(feedingIntervals.isEmpty ? 0 :
                            feedingIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a < b ? a : b), l10n),
                          Icons.speed, Colors.green),
                        _statCard(ls('max_interval'),
                          _formatInterval(feedingIntervals.isEmpty ? 0 :
                            feedingIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b), l10n),
                          Icons.slow_motion_video, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: feedingIntervals.reversed.take(5).map((iv) {
                        final from = iv['from'] as DateTime;
                        return Chip(
                          avatar: const Icon(Icons.access_time, size: 16),
                          label: Text('${from.hour}:${from.minute.toString().padLeft(2,'0')} → ${iv['minutes']}min'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 换尿布间隔统计
          if (diaperIntervals.isNotEmpty) ...[
            Text(ls('diaper_interval'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statCard(ls('avg_interval'),
                          _formatInterval(diaperIntervals.isEmpty ? 0 :
                            diaperIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a + b) ~/ diaperIntervals.length, l10n),
                          Icons.timelapse, Colors.orange),
                        _statCard(ls('min_interval'),
                          _formatInterval(diaperIntervals.isEmpty ? 0 :
                            diaperIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a < b ? a : b), l10n),
                          Icons.speed, Colors.amber),
                        _statCard(ls('max_interval'),
                          _formatInterval(diaperIntervals.isEmpty ? 0 :
                            diaperIntervals.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b), l10n),
                          Icons.slow_motion_video, Colors.deepOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 本周频次统计
          Text(ls('weekly_frequency'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard(ls('avg_per_day'), '${freqStats['avgFeedingPerDay']}${ls('times2')}', Icons.local_drink, Colors.blue),
                      _statCard(ls('total_this_week'), '${freqStats['totalFeeding']}${ls('times2')}', Icons.calendar_today, Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(ls('avg_per_day'), '${freqStats['avgDiaperPerDay']}${ls('times2')}', Icons.baby_changing_station, Colors.orange),
                      _statCard(ls('total_this_week'), '${freqStats['totalDiaper']}${ls('times2')}', Icons.calendar_today, Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 近7天喂奶趋势
          Text(ls('week_feeding_trend'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (weekFeedings.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                    barGroups: weekFeedings.asMap().entries.map((e) =>
                      BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(toY: e.value['count']!.toDouble(), color: Colors.blue, width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      ]),
                    ).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                        getTitlesWidget: (v, _) => Text(weekFeedings[v.toInt()]['label'] as String, style: const TextStyle(fontSize: 10)))),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 近7天换尿布趋势
          Text(ls('week_diaper_trend'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (weekDiapers.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                    barGroups: weekDiapers.asMap().entries.map((e) =>
                      BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(toY: e.value['count']!.toDouble(), color: Colors.orange, width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      ]),
                    ).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                        getTitlesWidget: (v, _) => Text(weekDiapers[v.toInt()]['label'] as String, style: const TextStyle(fontSize: 10)))),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
