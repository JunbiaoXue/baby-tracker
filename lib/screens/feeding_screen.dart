import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> with WidgetsBindingObserver {
  FeedingType _selectedType = FeedingType.breastDirect;
  final _minutesController = TextEditingController();
  final _mlController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isTimerRunning = false;
  int _breastSeconds = 0;
  BreastSide _currentSide = BreastSide.left;
  bool _left15minAlerted = false;
  bool _right15minAlerted = false;
  bool _useManualInput = false;
  DateTime _recordTime = DateTime.now(); // 允许选择历史时间
  
  DateTime? _timerStartTime;
  static const String _timerStartKey = 'feeding_timer_start';
  static const String _timerSideKey = 'feeding_timer_side';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
    _restoreTimerState();
  }

  Future<void> _initNotifications() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString(_timerStartKey);
    final sideStr = prefs.getString(_timerSideKey);
    
    if (startTimeStr != null) {
      final startTime = DateTime.parse(startTimeStr);
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed < 3600) {
        setState(() {
          _breastSeconds = elapsed;
          _isTimerRunning = true;
          _currentSide = sideStr == 'right' ? BreastSide.right : BreastSide.left;
          _check15MinAlert();
        });
      }
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isTimerRunning && _timerStartTime != null) {
      await prefs.setString(_timerStartKey, _timerStartTime!.toIso8601String());
      await prefs.setString(_timerSideKey, _currentSide == BreastSide.right ? 'right' : 'left');
    } else {
      await prefs.remove(_timerStartKey);
      await prefs.remove(_timerSideKey);
    }
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerStartKey);
    await prefs.remove(_timerSideKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minutesController.dispose();
    _mlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreTimerState();
    } else if (state == AppLifecycleState.paused) {
      _saveTimerState();
    }
  }

  void _check15MinAlert() {
    const alertSeconds = 15 * 60;
    
    if (_currentSide == BreastSide.left && _breastSeconds >= alertSeconds && !_left15minAlerted) {
      _left15minAlerted = true;
      _showNotification('左侧母乳喂养已达到 15 分钟', '是时候换到右侧了');
    } else if (_currentSide == BreastSide.right && _breastSeconds >= alertSeconds && !_right15minAlerted) {
      _right15minAlerted = true;
      _showNotification('右侧母乳喂养已达到 15 分钟', '喂养完成');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_timer',
          '喂养计时器',
          channelDescription: '母乳喂养计时提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final record = FeedingRecord(
      time: _recordTime,
      type: _selectedType,
      breastMinutes: _selectedType == FeedingType.breastDirect
          ? (_useManualInput 
              ? (_minutesController.text.isNotEmpty ? int.tryParse(_minutesController.text) : 0)
              : (_breastSeconds ~/ 60))
          : null,
      bottleMl: _selectedType != FeedingType.breastDirect
          ? int.tryParse(_mlController.text)
          : null,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      breastSide: _selectedType == FeedingType.breastDirect ? _currentSide : null,
    );
    await ds.addFeeding(record);
    setState(() {
      _breastSeconds = 0;
      _isTimerRunning = false;
      _left15minAlerted = false;
      _right15minAlerted = false;
      _timerStartTime = null;
    });
    await _clearTimerState();
    if (mounted) Navigator.pop(context);
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerStartTime = DateTime.now();
      _left15minAlerted = false;
      _right15minAlerted = false;
      _useManualInput = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isTimerRunning) return false;
      setState(() => _breastSeconds++);
      _check15MinAlert();
      return _isTimerRunning;
    });
  }

  void _switchSide() {
    setState(() {
      if (_currentSide == BreastSide.left) {
        _currentSide = BreastSide.right;
        _right15minAlerted = false;
        if (_isTimerRunning) _breastSeconds = 0;
      } else {
        _currentSide = BreastSide.left;
        _left15minAlerted = false;
        if (_isTimerRunning) _breastSeconds = 0;
      }
    });
  }

  Color _typeColor(FeedingType type) {
    switch (type) {
      case FeedingType.breastDirect: return Colors.pink;
      case FeedingType.breastBottle: return Colors.orange;
      case FeedingType.formula: return Colors.blue;
    }
  }

  IconData _typeIcon(FeedingType type) {
    switch (type) {
      case FeedingType.breastDirect: return Icons.child_care;
      case FeedingType.breastBottle: return Icons.local_drink;
      case FeedingType.formula: return Icons.water_drop;
    }
  }

  String _fmt(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: Text(ls('feeding_record')), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildForm(l10n);
          final r = records[index - 1];
          return _buildRecordItem(r, ds, l10n);
        },
      ),
    );
  }

  Widget _buildForm(L10nService l10n) {
    String ls(String k) => l10n.t(k);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ls('add_record'), style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text('${_recordTime.month}/${_recordTime.day} ${_recordTime.hour.toString().padLeft(2,'0')}:${_recordTime.minute.toString().padLeft(2,'0')}'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _recordTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_recordTime),
                      );
                      if (time != null) {
                        setState(() {
                          _recordTime = DateTime(
                            date.year, date.month, date.day,
                            time.hour, time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 喂养方式
            SegmentedButton<FeedingType>(
              segments: [
                ButtonSegment(value: FeedingType.breastDirect, label: Text(ls('breast_direct'))),
                ButtonSegment(value: FeedingType.breastBottle, label: Text(ls('breast_bottle'))),
                ButtonSegment(value: FeedingType.formula, label: Text(ls('formula'))),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) => setState(() => _selectedType = s.first),
            ),
            const SizedBox(height: 16),

            if (_selectedType == FeedingType.breastDirect) ...[
              // 母乳亲喂 - 模式选择：计时器或手动输入
              Row(
                children: [
                  FilterChip(
                    label: Text(ls('use_timer')),
                    selected: !_useManualInput,
                    onSelected: (_) => setState(() => _useManualInput = false),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(ls('manual_input')),
                    selected: _useManualInput,
                    onSelected: (_) => setState(() => _useManualInput = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_useManualInput) ...[
                // 计时器模式
                // 左右侧选择
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(ls('breast_side') + ': ', style: const TextStyle(fontSize: 14)),
                    ChoiceChip(
                      label: Text(ls('left_side')),
                      selected: _currentSide == BreastSide.left,
                      onSelected: (_) => setState(() {
                        _currentSide = BreastSide.left;
                        _left15minAlerted = false;
                        if (_isTimerRunning) _breastSeconds = 0;
                      }),
                      avatar: _currentSide == BreastSide.left ? const Icon(Icons.check, size: 18) : null,
                    ),
                    ChoiceChip(
                      label: Text(ls('right_side')),
                      selected: _currentSide == BreastSide.right,
                      onSelected: (_) => setState(() {
                        _currentSide = BreastSide.right;
                        _right15minAlerted = false;
                        if (_isTimerRunning) _breastSeconds = 0;
                      }),
                      avatar: _currentSide == BreastSide.right ? const Icon(Icons.check, size: 18) : null,
                    ),
                    if (_isTimerRunning)
                      ActionChip(
                        avatar: const Icon(Icons.swap_horiz, size: 18),
                        label: Text(ls('switch_side')),
                        onPressed: _switchSide,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // 计时器显示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_currentSide == BreastSide.left ? Colors.pink : Colors.purple).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentSide == BreastSide.left ? Colors.pink : Colors.purple,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_currentSide == BreastSide.left ? "左侧" : "右侧"}: ${_breastSeconds ~/ 60}${ls('minutes')}${_breastSeconds % 60}${ls('seconds')}',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: _currentSide == BreastSide.left ? Colors.pink : Colors.purple,
                        ),
                      ),
                      if (_breastSeconds >= 15 * 60)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '✅ ' + ls('completed_15min'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isTimerRunning)
                      FilledButton.icon(
                        onPressed: () => setState(() => _isTimerRunning = false),
                        icon: const Icon(Icons.stop),
                        label: Text(ls('stop_timer')),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _startTimer(),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(ls('start_timer')),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => setState(() { 
                        _breastSeconds = 0; 
                        _isTimerRunning = false; 
                        _left15minAlerted = false;
                        _right15minAlerted = false;
                      }),
                      child: Text(ls('reset')),
                    ),
                  ],
                ),
              ] else ...[
                // 手动输入模式
                Row(
                  children: [
                    Text(ls('breast_side') + ': ', style: const TextStyle(fontSize: 14)),
                    ChoiceChip(
                      label: Text(ls('left_side')),
                      selected: _currentSide == BreastSide.left,
                      onSelected: (_) => setState(() => _currentSide = BreastSide.left),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(ls('right_side')),
                      selected: _currentSide == BreastSide.right,
                      onSelected: (_) => setState(() => _currentSide = BreastSide.right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: ls('duration_minutes'),
                    border: const OutlineInputBorder(),
                    suffixText: ls('minutes'),
                  ),
                ),
              ],
            ] else ...[
              // 瓶喂/奶粉 - 输入量
              TextField(
                controller: _mlController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: ls('milk_amount_ml'),
                  border: const OutlineInputBorder(),
                  suffixText: 'ml',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: ls('note_optional'),
                border: const OutlineInputBorder(),
                hintText: ls('note_hint'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(ls('save_record')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(FeedingRecord r, DataService ds, L10nService l10n) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor(r.type).withOpacity(0.15),
          child: Icon(_typeIcon(r.type), color: _typeColor(r.type)),
        ),
        title: Text(r.typeName),
        subtitle: Text('${_fmt(r.time)}  ${r.displayAmount}${r.breastSide != null ? ' (${r.breastSide == BreastSide.left ? l10n.t('left_side') : l10n.t('right_side')})' : ''}${r.note != null ? '  📝${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ds.deleteFeeding(r.id),
        ),
      ),
    );
  }
}
