import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'services/l10n_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ds = DataService();
  await ds.init();
  final l10n = L10nService();
  await l10n.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ds),
        ChangeNotifierProvider.value(value: l10n),
      ],
      child: const BabyTrackerApp(),
    ),
  );
}

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<L10nService>();

    return MaterialApp(
      title: l10n.t('app_title'),
      debugShowCheckedModeBanner: false,
      locale: l10n.locale,
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
