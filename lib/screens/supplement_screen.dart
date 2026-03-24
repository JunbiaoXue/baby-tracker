import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplement_record.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

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

  String _ls(String key) => context.read<L10nService>().t(key);

  Future<void> _save() async {
    final ds = context.read<DataService>();
    await ds.setSupplement(SupplementRecord(
      date: DateTime.now(),
      tookAD: _tookAD,
      tookD3: _tookD3,
    ));
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

    return Scaffold(
      appBar: AppBar(title: Text(ls('supplement')), centerTitle: true),
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
                    Text(ls('today_supplement'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: Text(ls('vitamin_ad')),
                      subtitle: Text(ls('vitamin_ad_desc')),
                      value: _tookAD,
                      onChanged: (v) => setState(() => _tookAD = v),
                      secondary: CircleAvatar(
                        backgroundColor: _tookAD ? Colors.green.shade100 : Colors.grey.shade200,
                        child: const Icon(Icons.visibility, color: Colors.green),
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(ls('vitamin_d3')),
                      subtitle: Text(ls('vitamin_d3_desc')),
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
                        label: Text(ls('save')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ls('tip'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(ls('tip_content'), style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
