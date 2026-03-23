import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'feeding_screen.dart';
import 'diaper_screen.dart';
import 'supplement_screen.dart';
import 'sleep_screen.dart';
import 'growth_screen.dart';
import 'milestone_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final stats = ds.todayStats();
    final ongoingSleep = ds.ongoingSleep;
    final supplement = ds.todaySupplement();

    final screens = [
      _buildMainPage(ds, stats, ongoingSleep, supplement),
      const HistoryScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: '历史'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '统计'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildMainPage(DataService ds, Map stats, dynamic ongoingSleep, dynamic supplement) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.child_care, size: 28, color: Color(0xFF6EC6F0)),
                const SizedBox(width: 8),
                Text(ds.babyName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (ds.babyBirthday != null) ...[
                  Text('${_calcAge(ds.babyBirthday!)}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text('今日${_today()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 16),

            // 今日总结卡片
            _buildSummaryCard(stats, ongoingSleep, supplement),
            const SizedBox(height: 16),

            // 快捷记录
            Text('快捷记录', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickButtons(context),
            const SizedBox(height: 16),

            // 近期记录预览
            _buildRecentFeeding(ds),
            const SizedBox(height: 12),
            _buildRecentDiapers(ds),
          ],
        ),
      ),
    );
  }

  String _calcAge(DateTime birthday) {
    final now = DateTime.now();
    int months = (now.year - birthday.year) * 12 + now.month - birthday.month;
    if (now.day < birthday.day) months--;
    if (months < 0) return '';
    final years = months ~/ 12;
    final m = months % 12;
    if (years == 0) return '${m}个月';
    if (m == 0) return '${years}岁';
    return '${years}岁${m}个月';
  }

  String _today() {
    final now = DateTime.now();
    final weekdays = ['周日','周一','周二','周三','周四','周五','周六'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday % 7]}';
  }

  Widget _buildSummaryCard(Map stats, dynamic ongoingSleep, dynamic supplement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _statItem('喂奶', '${stats['feedingCount']}次', Icons.local_drink_outlined, Colors.blue),
                _statItem('奶量', '${stats['totalBottleMl']}ml', Icons.water_drop, Colors.cyan),
                _statItem('换尿布', '${stats['diaperCount']}次', Icons.baby_changing_station, Colors.orange),
                _statItem('睡眠', _formatSleep(stats['totalSleepMinutes']), Icons.bedtime, Colors.purple),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSupplementBadge('AD', supplement?.tookAD ?? false),
                const SizedBox(width: 8),
                _buildSupplementBadge('D3', supplement?.tookD3 ?? false),
                const SizedBox(width: 8),
                if (ongoingSleep != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bedtime, size: 14, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text('睡眠中', style: TextStyle(fontSize: 12, color: Colors.purple.shade700)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSupplementBadge(String name, bool taken) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: taken ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: taken ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 12, color: taken ? Colors.green.shade700 : Colors.grey),
      ),
    );
  }

  String _formatSleep(int minutes) {
    if (minutes == 0) return '0分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h${m}m' : '${m}分钟';
  }

  Widget _buildQuickButtons(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _quickBtn(context, '🍼 喂奶', Icons.local_drink, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedingScreen()))),
        _quickBtn(context, '🧷 换尿布', Icons.baby_changing_station, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaperScreen()))),
        _quickBtn(context, '💊 营养品', Icons.medication, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplementScreen()))),
        _quickBtn(context, '😴 睡眠', Icons.bedtime, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()))),
        _quickBtn(context, '📏 身高体重', Icons.straighten, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthScreen()))),
        _quickBtn(context, '🌟 里程碑', Icons.star, Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestoneScreen()))),
      ],
    );
  }

  Widget _quickBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label.split(' ')[1], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeeding(DataService ds) {
    final today = ds.todayFeedings().take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.local_drink, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Text('最近喂奶', style: Theme.of(context).textTheme.titleSmall),
            ]),
            const Divider(),
            if (today.isEmpty)
              const Padding(padding: EdgeInsets.all(8), child: Text('今日暂无记录', style: TextStyle(color: Colors.grey)))
            else
              ...today.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Text(_fmtTime(f.time), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Text(f.typeName, style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  Text(f.displayAmount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ]),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDiapers(DataService ds) {
    final today = ds.todayDiapers().take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.baby_changing_station, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              Text('最近换尿布', style: Theme.of(context).textTheme.titleSmall),
            ]),
            const Divider(),
            if (today.isEmpty)
              const Padding(padding: EdgeInsets.all(8), child: Text('今日暂无记录', style: TextStyle(color: Colors.grey)))
            else
              ...today.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Text(_fmtTime(d.time), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Text(d.typeName, style: const TextStyle(fontSize: 13)),
                  if (d.poopColor != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: _parseColor(d.poopColor!),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ]),
              )),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) {
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  Color _parseColor(String color) {
    final map = {
      '黄色': Colors.yellow.shade700,
      '棕色': Colors.brown.shade400,
      '绿色': Colors.green.shade400,
      '黑色': Colors.black87,
      '灰色': Colors.grey,
      '奶瓣': Colors.amber.shade200,
      '水便': Colors.blue.shade200,
    };
    return map[color] ?? Colors.grey;
  }
}
