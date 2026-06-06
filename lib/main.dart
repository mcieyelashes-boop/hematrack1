import 'package:flutter/material.dart';

import 'screens/child_list_screen.dart';
import 'services/app_storage.dart';
import 'services/child_repository.dart';
import 'services/hemangioma_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.instance.init();
  await ChildRepository.instance.load();
  await HemangiomaRepository.instance.load();
  runApp(const HemaTrackApp());
}

class HemaTrackApp extends StatelessWidget {
  const HemaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HemaTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const ChildListScreen(),
    );
  }
}
