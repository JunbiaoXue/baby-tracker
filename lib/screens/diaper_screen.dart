import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diaper_record.dart';
import '../services/data_service.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  DiaperType _selectedType = DiaperType.pee;
  String? _poopColor;
  final _noteController = TextEditingController();

  final List<String> poopColors = ['黄色','棕色','绿色','黑色','灰色','奶瓣','水便'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final record = DiaperRecord(
      time: DateTime.now(),
      type: _selectedType,
      poopColor: (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ? _poopColor : null,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await ds.addDiaper(record);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('换尿布记录'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) return _buildForm();
          final r = records[index - 1];
          return _buildRecordItem(r, ds);
        },
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新增记录', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SegmentedButton<DiaperType>(
              segments: const [
                ButtonSegment(value: DiaperType.pee, label: Text('小便')),
                ButtonSegment(value: DiaperType.poop, label: Text('大便')),
                ButtonSegment(value: DiaperType.both, label: Text('两者都有')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) => setState(() => _selectedType = s.first),
            ),
            if (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ...[
              const SizedBox(height: 12),
              const Text('大便颜色', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: poopColors.map((c) => ChoiceChip(
                  label: Text(c),
                  selected: _poopColor == c,
                  onSelected: (_) => setState(() => _poopColor = c),
                  selectedColor: Colors.orange.shade100,
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注 (可选)',
                border: OutlineInputBorder(),
                hintText: '如：形状异常/血丝等',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('保存记录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(DiaperRecord r, DataService ds) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.15),
          child: const Icon(Icons.baby_changing_station, color: Colors.orange),
        ),
        title: Text(r.typeName),
        subtitle: Text('${_fmt(r.time)}${r.poopColor != null ? '  颜色: ${r.poopColor}' : ''}${r.note != null ? '  📝${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ds.deleteDiaper(r.id),
        ),
      ),
    );
  }

  String _fmt(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }
}
