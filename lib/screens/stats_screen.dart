import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final stats = ds.todayStats();
    final weekFeedings = _getWeekData(ds, 'feeding');
    final weekDiapers = _getWeekData(ds, 'diaper');

    return Scaffold(
      appBar: AppBar(title: const Text('数据统计'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 今日概况
          Text('今日概况', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard('喂奶次数', '${stats['feedingCount']}次', Icons.local_drink, Colors.blue),
                      _statCard('总奶量', '${stats['totalBottleMl']}ml', Icons.water_drop, Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard('换尿布', '${stats['diaperCount']}次', Icons.baby_changing_station, Colors.orange),
                      _statCard('小便/大便', '${stats['peeCount']}/${stats['poopCount']}', Icons.show_chart, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard('睡眠时长', _formatSleep(stats['totalSleepMinutes']), Icons.bedtime, Colors.purple),
                      _statCard('母乳时长', '${stats['totalBreastMinutes']}分钟', Icons.child_care, Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 近7天喂奶趋势
          Text('近7天喂奶次数', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
          Text('近7天换尿布次数', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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

  List<Map> _getWeekData(DataService ds, String type) {
    final now = DateTime.now();
    final result = <Map>[];
    final weekdays = ['周一','周二','周三','周四','周五','周六','周日'];

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

  String _formatSleep(int minutes) {
    if (minutes == 0) return '0分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h${m}m' : '${m}分钟';
  }
}
