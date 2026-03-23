import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/growth_record.dart';
import '../services/data_service.dart';

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
        const SnackBar(content: Text('已保存！'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.growthRecords.take(20).toList();
    final latest = records.isNotEmpty ? records.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('身高体重记录'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (latest != null) _buildLatestCard(latest),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('新增记录', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildField('体重 (kg)', _weightController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('身长 (cm)', _heightController)),
                  ]),
                  const SizedBox(height: 12),
                  _buildField('头围 (cm)', _headController),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
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
                      label: const Text('保存记录'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('历史记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...records.map((r) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.straighten, color: Colors.white),
              ),
              title: Text('${r.date.month}/${r.date.day}'),
              subtitle: Text([
                if (r.weightKg != null) '体重: ${r.weightKg}kg',
                if (r.heightCm != null) '身长: ${r.heightCm}cm',
                if (r.headCircumferenceCm != null) '头围: ${r.headCircumferenceCm}cm',
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

  Widget _buildLatestCard(GrowthRecord r) {
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
              const Text('最新记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text('${r.date.month}/${r.date.day}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                if (r.weightKg != null) _latestItem('体重', '${r.weightKg}', 'kg', Colors.blue),
                if (r.heightCm != null) _latestItem('身长', '${r.heightCm}', 'cm', Colors.green),
                if (r.headCircumferenceCm != null) _latestItem('头围', '${r.headCircumferenceCm}', 'cm', Colors.orange),
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
