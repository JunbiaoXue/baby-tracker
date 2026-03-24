import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/milestone_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

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

  // Preset milestones - key in code matches translation key prefix
  final Map<String, List<String>> _presetMilestones = {
    'milestone': ['first_smile', 'roll_over', 'sit_up', 'crawl', 'stand', 'first_steps', 'first_words', 'teething', 'recognize_people', 'stranger_anxiety'],
    'hospital': ['checkup', 'visit', 'review', 'medicine'],
    'vaccine': ['vaccination'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _ls(String key) => context.read<L10nService>().t(key);

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
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);
    final ds = context.watch<DataService>();
    final records = ds.milestoneRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: Text(ls('milestone')), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) return _buildForm(l10n);
          final r = records[index - 1];
          return _buildRecordItem(r, ds);
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
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'milestone', label: Text(ls('milestone_tab'))),
                ButtonSegment(value: 'hospital', label: Text(ls('hospital_tab'))),
                ButtonSegment(value: 'vaccine', label: Text(ls('vaccine_tab'))),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 12),
            // 预设快捷选项
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_presetMilestones[_category] ?? []).map((presetKey) =>
                ActionChip(
                  label: Text(ls(presetKey), style: const TextStyle(fontSize: 12)),
                  onPressed: () => _titleController.text = ls(presetKey),
                )
              ).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: ls('title'), border: const OutlineInputBorder()),
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
                decoration: InputDecoration(
                  labelText: ls('date'),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(labelText: ls('note_optional'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(ls('save')),
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
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
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
