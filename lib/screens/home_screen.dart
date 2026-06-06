import 'package:flutter/material.dart';

import 'child_list_screen.dart';

// Legacy entry point — delegates to ChildListScreen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const ChildListScreen();
}
