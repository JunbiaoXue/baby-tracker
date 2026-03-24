import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/l10n_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();
    String ls(String k) => l10n.t(k);

    return Scaffold(
      appBar: AppBar(
        title: Text(ls('history_title')),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: ls('feeding')),
            Tab(text: ls('diaper')),
            Tab(text: ls('sleep')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _selectedDate = d);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                DateFormat('yyyy/MM/dd').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedingHistory(l10n),
                _buildDiaperHistory(l10n),
                _buildSleepHistory(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingHistory(L10nService l10n) {
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return Center(child: Text(l10n.t('no_records')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.local_drink, color: Colors.blue),
            ),
            title: Text(r.typeName),
            subtitle: Text('${DateFormat('HH:mm').format(r.time)}  ${r.displayAmount}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteFeeding(r.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaperHistory(L10nService l10n) {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return Center(child: Text(l10n.t('no_records')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.baby_changing_station, color: Colors.orange),
            ),
            title: Text(r.typeName),
            subtitle: Text('${DateFormat('HH:mm').format(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteDiaper(r.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepHistory(L10nService l10n) {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((r) =>
      r.startTime.year == _selectedDate.year &&
      r.startTime.month == _selectedDate.month &&
      r.startTime.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return Center(child: Text(l10n.t('no_records')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: const Icon(Icons.bedtime, color: Colors.purple),
            ),
            title: Text(r.isOngoing ? l10n.t('sleeping') : l10n.t('sleep')),
            subtitle: Text(
              '${DateFormat('HH:mm').format(r.startTime)}${r.endTime != null ? ' - ${DateFormat('HH:mm').format(r.endTime!)}' : ''}  ${r.durationStr}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteSleep(r.id),
            ),
          ),
        );
      },
    );
  }
}
