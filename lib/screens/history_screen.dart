import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '喂奶'),
            Tab(text: '换尿布'),
            Tab(text: '睡眠'),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                DateFormat('yyyy年MM月dd日').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedingHistory(),
                _buildDiaperHistory(),
                _buildSleepHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingHistory() {
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
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

  Widget _buildDiaperHistory() {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
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

  Widget _buildSleepHistory() {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((r) =>
      r.startTime.year == _selectedDate.year &&
      r.startTime.month == _selectedDate.month &&
      r.startTime.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.bedtime, color: Colors.purple),
            ),
            title: Text(r.isOngoing ? '睡眠中' : '睡眠'),
            subtitle: Text('${DateFormat('HH:mm').format(r.startTime)}${r.endTime != null ? ' - ${DateFormat('HH:mm').format(r.endTime!)}' : ''}  ${r.durationStr}'),
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
