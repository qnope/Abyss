import 'package:flutter/material.dart';
import 'data/game_repository.dart';
import 'presentation/screens/menu/main_menu_screen.dart';
import 'presentation/theme/abyss_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameRepository.initialize();
  runApp(AbyssApp(repository: GameRepository()));
}

class AbyssApp extends StatelessWidget {
  final GameRepository repository;

  const AbyssApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABYSSES',
      theme: AbyssTheme.create(),
      home: MainMenuScreen(repository: repository),
    );
  }
}
