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
        count = ds.feedingRecords.where((r) =>
          r.time.year == d.year && r.time.month == d.month && r.time.day == d.day
        ).length;
      } else {
        count = ds.diaperRecords.where((r) =>
          r.time.year == d.year && r.time.month == d.month && r.time.day == d.day
        ).length;
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
    String ls(String k) => l10n.t(k);
    final stats = ds.todayStats();
    final weekFeedings = _getWeekData(ds, 'feeding', l10n);
    final weekDiapers = _getWeekData(ds, 'diaper', l10n);

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
          const SizedBox(height: 24),

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
                      BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value['count']!.toDouble(),
                            color: Colors.blue,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      )
                    ).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            weekFeedings[v.toInt()]['label'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

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
                      BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value['count']!.toDouble(),
                            color: Colors.orange,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      )
                    ).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            weekDiapers[v.toInt()]['label'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
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
