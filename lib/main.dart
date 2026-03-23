import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ds = DataService();
  await ds.init();
  runApp(ChangeNotifierProvider.value(value: ds, child: const BabyTrackerApp()));
}

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝宝记录',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6EC6F0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'PingFang',
      ),
      home: const HomeScreen(),
    );
  }
}
