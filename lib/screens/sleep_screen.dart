import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record.dart';
import '../services/data_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isOngoing = false;
  DateTime? _startTime;
  SleepQuality _quality = SleepQuality.good;

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    final ongoing = ds.ongoingSleep;
    if (ongoing != null) {
      _isOngoing = true;
      _startTime = ongoing.startTime;
    }
  }

  Future<void> _startSleep() async {
    final ds = context.read<DataService>();
    final record = SleepRecord(startTime: DateTime.now());
    await ds.addSleep(record);
    setState(() {
      _isOngoing = true;
      _startTime = record.startTime;
    });
  }

  Future<void> _endSleep() async {
    final ds = context.read<DataService>();
    final ongoing = ds.ongoingSleep;
    if (ongoing == null) return;

    final updated = SleepRecord(
      id: ongoing.id,
      startTime: ongoing.startTime,
      endTime: DateTime.now(),
      quality: _quality,
    );
    await ds.updateSleep(updated);
    setState(() {
      _isOngoing = false;
      _startTime = null;
      _quality = SleepQuality.good;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((s) => !s.isOngoing).take(20).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('睡眠记录'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前状态卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _isOngoing ? Icons.bedtime : Icons.wb_twilight,
                    size: 56,
                    color: _isOngoing ? Colors.purple : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isOngoing ? '宝宝正在睡觉 😴' : '宝宝醒着 ☀️',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_isOngoing && _startTime != null) ...[
                    const SizedBox(height: 4),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (_, __) {
                        final duration = DateTime.now().difference(_startTime!);
                        return Text(
                          '已睡 ${duration.inHours}小时${duration.inMinutes % 60}分钟',
                          style: TextStyle(fontSize: 16, color: Colors.purple.shade600),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!_isOngoing)
                    FilledButton.icon(
                      onPressed: _startSleep,
                      icon: const Icon(Icons.bedtime),
                      label: const Text('开始记录睡眠'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.purple),
                    )
                  else ...[
                    const Text('睡眠质量'),
                    const SizedBox(height: 8),
                    SegmentedButton<SleepQuality>(
                      segments: const [
                        ButtonSegment(value: SleepQuality.good, label: Text('好')),
                        ButtonSegment(value: SleepQuality.normal, label: Text('一般')),
                        ButtonSegment(value: SleepQuality.crying, label: Text('哭闹')),
                      ],
                      selected: {_quality},
                      onSelectionChanged: (s) => setState(() => _quality = s.first),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _endSleep,
                      icon: const Icon(Icons.wb_sunny),
                      label: const Text('醒来 - 结束睡眠'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('历史记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (records.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('暂无历史记录')))
          else
            ...records.map((r) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.15),
                  child: const Icon(Icons.bedtime, color: Colors.purple),
                ),
                title: Text('${_fmt(r.startTime)} 开始'),
                subtitle: Text('睡眠时长: ${r.durationStr}${r.quality != null ? '  质量: ${_qualityName(r.quality!)}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ds.deleteSleep(r.id),
                ),
              ),
            )),
        ],
      ),
    );
  }

  String _fmt(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  String _qualityName(SleepQuality q) {
    switch (q) {
      case SleepQuality.good: return '好';
      case SleepQuality.normal: return '一般';
      case SleepQuality.crying: return '哭闹';
    }
  }
}
