import 'dart:ui';

import 'package:flutter/material.dart';
import 'data/game_repository.dart';
import 'data/language_settings.dart';
import 'presentation/abyss_material_app.dart';
import 'presentation/screens/menu/main_menu_screen.dart';
import 'presentation/widgets/backdrop/backdrop_prewarm.dart';
import 'presentation/widgets/warm_up/game_warm_up.dart';
import 'presentation/widgets/warm_up/warm_up_layer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The home art rasterizes while the saves open, not after.
  final view = PlatformDispatcher.instance.implicitView;
  if (view != null) prewarmBackdrop(view);
  await GameRepository.initialize();
  final language = await LanguageSettings.open();
  runApp(AbyssApp(repository: GameRepository(), language: language));
}

class AbyssApp extends StatelessWidget {
  final GameRepository repository;
  final LanguageSettings language;

  const AbyssApp({super.key, required this.repository, required this.language});

  @override
  Widget build(BuildContext context) {
    return AbyssMaterialApp(
      language: language,
      // While the menu shows, every icon and sprite is rasterized and the
      // game screens are pre-drawn out of sight, so none of them waits.
      builder:
          (context, child) => WarmUpLayer(
            load: preloadGameArt,
            pages: gameWarmUpPages,
            child: child!,
          ),
      home: MainMenuScreen(repository: repository),
    );
  }
}
