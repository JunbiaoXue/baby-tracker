import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/milestone_record.dart';
import '../services/data_service.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  String _category = 'milestone';
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final _presetMilestones = {
    'milestone': ['第一次微笑', '翻身', '独坐', '爬行', '站立', '迈步走', '叫爸爸妈妈', '长牙', '认人', '认生'],
    'hospital': ['体检', '就诊', '复查', '用药'],
    'vaccine': ['疫苗接种'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    final ds = context.read<DataService>();
    await ds.addMilestone(MilestoneRecord(
      date: _selectedDate,
      title: _titleController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      category: _category,
    ));
    _titleController.clear();
    _noteController.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.milestoneRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('里程碑 & 备忘'), centerTitle: true),
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
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'milestone', label: Text('🌟 里程碑')),
                ButtonSegment(value: 'hospital', label: Text('🏥 就医')),
                ButtonSegment(value: 'vaccine', label: Text('💉 疫苗')),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 12),
            // 预设快捷选项
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_presetMilestones[_category] ?? []).map((preset) =>
                ActionChip(
                  label: Text(preset, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _titleController.text = preset,
                )
              ).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日期',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '备注 (可选)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(MilestoneRecord r, DataService ds) {
    IconData icon;
    Color color;
    String emoji;
    switch (r.category) {
      case 'hospital': icon = Icons.local_hospital; color = Colors.red; emoji = '🏥';
      case 'vaccine': icon = Icons.vaccines; color = Colors.green; emoji = '💉';
      default: icon = Icons.star; color = Colors.amber; emoji = '🌟';
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text('$emoji ${r.title}'),
        subtitle: Text('${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ds.deleteMilestone(r.id),
        ),
      ),
    );
  }
}
