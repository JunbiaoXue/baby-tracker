import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/growth_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _save() async {
    final ds = context.read<DataService>();
    await ds.addGrowth(GrowthRecord(
      date: DateTime.now(),
      weightKg: double.tryParse(_weightController.text),
      heightCm: double.tryParse(_heightController.text),
      headCircumferenceCm: double.tryParse(_headController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    ));
    _weightController.clear();
    _heightController.clear();
    _headController.clear();
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_ls('saved')), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);
    final ds = context.watch<DataService>();
    final records = ds.growthRecords.take(20).toList();
    final latest = records.isNotEmpty ? records.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(ls('growth_record')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (latest != null) _buildLatestCard(latest, l10n),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ls('add_record'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildField(ls('weight_kg'), _weightController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(ls('height_cm'), _heightController)),
                  ]),
                  const SizedBox(height: 12),
                  _buildField(ls('head_cm'), _headController),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: ls('note_optional'),
                      border: const OutlineInputBorder(),
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
          ),
          const SizedBox(height: 16),
          Text(ls('history_records'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...records.map((r) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.straighten, color: Colors.white),
              ),
              title: Text('${r.date.month}/${r.date.day}'),
              subtitle: Text([
                if (r.weightKg != null) '${ls('weight')}: ${r.weightKg}kg',
                if (r.heightCm != null) '${ls('height')}: ${r.heightCm}cm',
                if (r.headCircumferenceCm != null) '${ls('head')}: ${r.headCircumferenceCm}cm',
              ].join('  ')),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => ds.deleteGrowth(r.id),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLatestCard(GrowthRecord r, L10nService l10n) {
    String ls(String k) => l10n.t(k);
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.straighten, color: Colors.teal),
              const SizedBox(width: 8),
              Text(ls('latest_record'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text('${r.date.month}/${r.date.day}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                if (r.weightKg != null) _latestItem(ls('weight'), '${r.weightKg}', 'kg', Colors.blue),
                if (r.heightCm != null) _latestItem(ls('height'), '${r.heightCm}', 'cm', Colors.green),
                if (r.headCircumferenceCm != null) _latestItem(ls('head'), '${r.headCircumferenceCm}', 'cm', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestItem(String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text('$label($unit)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
