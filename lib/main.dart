import 'dart:ui';

import 'package:flutter/material.dart';
import 'data/game_repository.dart';
import 'presentation/l10n/abyss_locale.dart';
import 'presentation/screens/menu/main_menu_screen.dart';
import 'presentation/theme/abyss_theme.dart';
import 'presentation/widgets/backdrop/backdrop_prewarm.dart';
import 'presentation/widgets/warm_up/game_warm_up.dart';
import 'presentation/widgets/warm_up/warm_up_layer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The home art rasterizes while the saves open, not after.
  final view = PlatformDispatcher.instance.implicitView;
  if (view != null) prewarmBackdrop(view);
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
      localizationsDelegates: AbyssLocale.delegates,
      supportedLocales: AbyssLocale.supported,
      localeListResolutionCallback: AbyssLocale.resolveList,
      // While the menu shows, every icon and sprite is rasterized and the
      // game screens are pre-drawn out of sight, so none of them waits.
      builder: (context, child) => WarmUpLayer(
        load: preloadGameArt,
        pages: gameWarmUpPages,
        child: child!,
      ),
      home: MainMenuScreen(repository: repository),
    );
  }
}
