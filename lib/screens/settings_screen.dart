import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    _nameController.text = ds.babyName;
    _birthday = ds.babyBirthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _ls(String key) => context.read<L10nService>().t(key);
  String _lw(String key) => context.watch<L10nService>().t(key);

  Future<void> _saveBabyInfo() async {
    if (_nameController.text.isEmpty || _birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_ls('please_fill'))),
      );
      return;
    }
    final ds = context.read<DataService>();
    await ds.setBabyInfo(_nameController.text, _birthday!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_ls('saved')), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: _ls('about_app'),
      applicationVersion: '2.0.0',
      children: [
        Text(_ls('about_description')),
        const SizedBox(height: 8),
        Text(_ls('about_features'), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();

    return Scaffold(
      appBar: AppBar(title: Text(_lw('settings')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 宝宝信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.child_care, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(_lw('baby_info'), style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: _lw('baby_name'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => _birthday = d);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _lw('birth_date'),
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _birthday != null
                            ? '${_birthday!.year}/${_birthday!.month}/${_birthday!.day}'
                            : _lw('please_fill'),
                        style: TextStyle(color: _birthday == null ? Colors.grey : null),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveBabyInfo,
                      icon: const Icon(Icons.check),
                      label: Text(_lw('save')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 语言切换
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.language, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(_lw('language'), style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 12),
                  ...L10nService.supportedLocales.entries.map((e) {
                    return RadioListTile<String>(
                      title: Text(e.value),
                      value: e.key,
                      groupValue: l10n.locale.languageCode,
                      onChanged: (v) {
                        if (v != null) l10n.setLocale(v);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 关于
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(_lw('version')),
                  trailing: const Text('2.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: Text(_lw('about')),
                  subtitle: Text(_lw('about_subtitle')),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据导出
          Card(
            child: ListTile(
              leading: const Icon(Icons.download, color: Colors.blue),
              title: Text(_lw('data_export')),
              subtitle: Text(_lw('data_export_desc')),
              trailing: const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
