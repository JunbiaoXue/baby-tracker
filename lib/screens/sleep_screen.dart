import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isOngoing = false;
  DateTime? _startTime;
  DateTime _recordStartTime = DateTime.now(); // 允许选择历史时间
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

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _startSleep() async {
    final ds = context.read<DataService>();
    final record = SleepRecord(startTime: _recordStartTime);
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

  String _fmt(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  String _qualityName(SleepQuality q, L10nService l10n) {
    switch (q) {
      case SleepQuality.good: return l10n.t('quality_good');
      case SleepQuality.normal: return l10n.t('quality_normal');
      case SleepQuality.crying: return l10n.t('quality_crying');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((s) => !s.isOngoing).take(20).toList();

    return Scaffold(
      appBar: AppBar(title: Text(ls('sleep_record')), centerTitle: true),
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
                    _isOngoing ? ls('baby_sleeping') : ls('baby_awake'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_isOngoing && _startTime != null) ...[
                    const SizedBox(height: 4),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (_, __) {
                        final duration = DateTime.now().difference(_startTime!);
                        final hk = ls('hours');
                        final mk = ls('minutes2');
                        return Text(
                          '${ls('has_slept')} ${duration.inHours}${hk}${duration.inMinutes % 60}$mk',
                          style: TextStyle(fontSize: 16, color: Colors.purple.shade600),
                        );
                      },
                    ),
                  ],
                  if (!_isOngoing) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text('${_recordStartTime.month}/${_recordStartTime.day} ${_recordStartTime.hour.toString().padLeft(2,'0')}:${_recordStartTime.minute.toString().padLeft(2,'0')}'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _recordStartTime,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_recordStartTime),
                          );
                          if (time != null) {
                            setState(() {
                              _recordStartTime = DateTime(
                                date.year, date.month, date.day,
                                time.hour, time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!_isOngoing)
                    FilledButton.icon(
                      onPressed: _startSleep,
                      icon: const Icon(Icons.bedtime),
                      label: Text(ls('start_record_sleep')),
                      style: FilledButton.styleFrom(backgroundColor: Colors.purple),
                    )
                  else ...[
                    Text(ls('sleep_quality')),
                    const SizedBox(height: 8),
                    SegmentedButton<SleepQuality>(
                      segments: [
                        ButtonSegment(value: SleepQuality.good, label: Text(ls('quality_good'))),
                        ButtonSegment(value: SleepQuality.normal, label: Text(ls('quality_normal'))),
                        ButtonSegment(value: SleepQuality.crying, label: Text(ls('quality_crying'))),
                      ],
                      selected: {_quality},
                      onSelectionChanged: (s) => setState(() => _quality = s.first),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _endSleep,
                      icon: const Icon(Icons.wb_sunny),
                      label: Text(ls('wake_up')),
                      style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(ls('sleep_history'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (records.isEmpty)
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(ls('no_history'))))
          else
            ...records.map((r) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.15),
                  child: const Icon(Icons.bedtime, color: Colors.purple),
                ),
                title: Text('${_fmt(r.startTime)}'),
                subtitle: Text(
                  '${ls('sleep_duration')}: ${r.durationStr}${r.quality != null ? '  ${ls('quality')}: ${_qualityName(r.quality!, l10n)}' : ''}',
                ),
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
}
