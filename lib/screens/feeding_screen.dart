import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/feeding_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  FeedingType _selectedType = FeedingType.breastDirect;
  final _minutesController = TextEditingController();
  final _mlController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isTimerRunning = false;
  int _breastSeconds = 0;

  @override
  void dispose() {
    _minutesController.dispose();
    _mlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final record = FeedingRecord(
      time: DateTime.now(),
      type: _selectedType,
      breastMinutes: _selectedType == FeedingType.breastDirect
          ? (_minutesController.text.isNotEmpty ? int.tryParse(_minutesController.text) : _breastSeconds ~/ 60)
          : null,
      bottleMl: _selectedType != FeedingType.breastDirect
          ? int.tryParse(_mlController.text)
          : null,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await ds.addFeeding(record);
    if (mounted) Navigator.pop(context);
  }

  void _startTimer() {
    setState(() => _isTimerRunning = true);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isTimerRunning) return false;
      setState(() => _breastSeconds++);
      return _isTimerRunning;
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
            Text(ls('add_record'), style: Theme.of(context).textTheme.titleMedium),
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
              // 母乳亲喂 - 计时器
              Row(children: [
                Text(
                  '${ls('duration')}: ${_breastSeconds ~/ 60}${ls('minutes')}${_breastSeconds % 60}${ls('seconds')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
              ]),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => setState(() { _breastSeconds = 0; _isTimerRunning = false; }),
                child: Text(ls('reset')),
              ),
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
        subtitle: Text('${_fmt(r.time)}  ${r.displayAmount}${r.note != null ? '  📝${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ds.deleteFeeding(r.id),
        ),
      ),
    );
  }
}
