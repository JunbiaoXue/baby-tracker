import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplement_record.dart';
import '../services/data_service.dart';

class SupplementScreen extends StatefulWidget {
  const SupplementScreen({super.key});

  @override
  State<SupplementScreen> createState() => _SupplementScreenState();
}

class _SupplementScreenState extends State<SupplementScreen> {
  bool _tookAD = false;
  bool _tookD3 = false;

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    final today = ds.todaySupplement();
    if (today != null) {
      _tookAD = today.tookAD;
      _tookD3 = today.tookD3;
    }
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    await ds.setSupplement(SupplementRecord(
      date: DateTime.now(),
      tookAD: _tookAD,
      tookD3: _tookD3,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存！'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('营养补充'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.medication, size: 48, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text('今日营养补充', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('维生素 AD'),
                      subtitle: const Text('促进骨骼发育、免疫力'),
                      value: _tookAD,
                      onChanged: (v) => setState(() => _tookAD = v),
                      secondary: CircleAvatar(
                        backgroundColor: _tookAD ? Colors.green.shade100 : Colors.grey.shade200,
                        child: const Icon(Icons.visibility, color: Colors.green),
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('维生素 D3'),
                      subtitle: const Text('促进钙吸收、预防佝偻病'),
                      value: _tookD3,
                      onChanged: (v) => setState(() => _tookD3 = v),
                      secondary: CircleAvatar(
                        backgroundColor: _tookD3 ? Colors.blue.shade100 : Colors.grey.shade200,
                        child: const Icon(Icons.wb_sunny, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
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
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 小贴士', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('AD 和 D3 通常在宝宝出生后 15 天开始补充，建议在早上喂奶后服用。具体用量请遵医嘱。', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
