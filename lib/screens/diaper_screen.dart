import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diaper_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  DiaperType _selectedType = DiaperType.pee;
  String? _poopColor;
  final _noteController = TextEditingController();
  DateTime _recordTime = DateTime.now(); // 允许选择历史时间

  // Poop colors with bilingual labels
  final List<Map<String, String>> _poopColors = [
    {'zh': '黄色', 'en': 'Yellow'},
    {'zh': '棕色', 'en': 'Brown'},
    {'zh': '绿色', 'en': 'Green'},
    {'zh': '黑色', 'en': 'Black'},
    {'zh': '灰色', 'en': 'Grey'},
    {'zh': '奶瓣', 'en': 'Milk Curd'},
    {'zh': '水便', 'en': 'Watery'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final record = DiaperRecord(
      time: _recordTime,
      type: _selectedType,
      poopColor: (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ? _poopColor : null,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await ds.addDiaper(record);
    if (mounted) Navigator.pop(context);
  }

  String _fmt(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: Text(ls('diaper_record')), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1,
        itemBuilder: (ctx, index) {
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
            SegmentedButton<DiaperType>(
              segments: [
                ButtonSegment(value: DiaperType.pee, label: Text(ls('pee'))),
                ButtonSegment(value: DiaperType.poop, label: Text(ls('poop'))),
                ButtonSegment(value: DiaperType.both, label: Text(ls('both'))),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) => setState(() => _selectedType = s.first),
            ),
            if (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ...[
              const SizedBox(height: 12),
              Text(ls('poop_color'), style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _poopColors.map((c) {
                  final label = l10n.locale.languageCode == 'en' ? c['en']! : c['zh']!;
                  return ChoiceChip(
                    label: Text(label),
                    selected: _poopColor == c['zh'],
                    onSelected: (_) => setState(() => _poopColor = c['zh']),
                    selectedColor: Colors.orange.shade100,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: ls('note_optional'),
                border: const OutlineInputBorder(),
                hintText: ls('poop_hint'),
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

  Widget _buildRecordItem(DiaperRecord r, DataService ds, L10nService l10n) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: const Icon(Icons.baby_changing_station, color: Colors.orange),
        ),
        title: Text(r.typeName),
        subtitle: Text('${_fmt(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}${r.note != null ? '  📝${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ds.deleteDiaper(r.id),
        ),
      ),
    );
  }
}
