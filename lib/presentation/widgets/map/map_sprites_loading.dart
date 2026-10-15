import 'package:flutter/widgets.dart';

import 'map_creature_sheets.dart';
import 'map_sprites.dart';

/// Gives a map's state the shared [MapSprites]: at once when already
/// loaded, else as soon as they are. Once they are shown, the sheets of
/// the living creatures are built after the frame, a few at a time, so
/// the map first appears with them bobbing, then undulating.
mixin MapSpritesLoading<T extends StatefulWidget> on State<T> {
  /// The map's sprites, `null` while they load.
  MapSprites? get sprites => _sprites;
  MapSprites? _sprites;

  @override
  void initState() {
    super.initState();
    final ready = MapSprites.ready;
    if (ready != null) return _show(ready);
    MapSprites.load().then(
      (sprites) {
        if (mounted) setState(() => _show(sprites));
      },
      onError: (Object error) => debugPrint('Map sprites failed: $error'),
    );
  }

  void _show(MapSprites sprites) {
    _sprites = sprites;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MapCreatureSheets.preload(sprites).catchError(
        (Object error) => debugPrint('Creature sheets failed: $error'),
      );
    });
  }
}
