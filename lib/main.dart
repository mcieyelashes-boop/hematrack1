import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/child_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_storage.dart';
import 'services/child_repository.dart';
import 'services/hemangioma_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  await AppStorage.instance.init();
  await ChildRepository.instance.load();
  await HemangiomaRepository.instance.load();
  final onboardingDone =
      await AppStorage.instance.getBool('onboarding_done');
  runApp(HemaTrackApp(showWelcome: !onboardingDone));
}

class HemaTrackApp extends StatelessWidget {
  final bool showWelcome;
  const HemaTrackApp({super.key, required this.showWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HemaTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: showWelcome
          ? const WelcomeScreen()
          : const ChildListScreen(),
    );
  }
}
