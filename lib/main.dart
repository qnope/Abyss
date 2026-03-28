import 'package:flutter/material.dart';
import 'data/game_repository.dart';
import 'presentation/screens/main_menu_screen.dart';
import 'presentation/theme/abyss_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameRepository.initialize();
  runApp(const AbyssApp());
}

class AbyssApp extends StatelessWidget {
  const AbyssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABYSSES',
      theme: AbyssTheme.create(),
      home: const MainMenuScreen(),
    );
  }
}
