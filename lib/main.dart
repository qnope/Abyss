import 'package:flutter/material.dart';
import 'data/game_repository.dart';
import 'presentation/screens/menu/main_menu_screen.dart';
import 'presentation/theme/abyss_theme.dart';
import 'presentation/widgets/common/svg_raster_cache.dart';
import 'presentation/widgets/map/map_sprites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameRepository.initialize();
  runApp(AbyssApp(repository: GameRepository()));
  WidgetsBinding.instance.addPostFrameCallback((_) => _preloadArt());
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

/// Rasterizes every icon and map sprite while the main menu shows, so the
/// game screens draw them from bitmaps on their first frame. A failure
/// only means icons load lazily, so it never blocks startup.
Future<void> _preloadArt() async {
  try {
    await SvgRasterCache.preloadAll();
    await MapSprites.load();
  } catch (_) {}
}
