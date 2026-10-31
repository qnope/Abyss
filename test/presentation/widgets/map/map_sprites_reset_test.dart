import 'package:abyss/presentation/widgets/map/living_creatures.dart';
import 'package:abyss/presentation/widgets/map/map_creature_sheets.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/stalled_loads.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  group('MapSprites', () {
    testWidgets('forgets the sprites loaded', (tester) async {
      final sprites = await loadsWithin(tester, MapSprites.load);
      expect(MapSprites.ready, same(sprites));

      MapSprites.debugReset();

      expect(MapSprites.ready, isNull);
      final again = await loadsWithin(tester, MapSprites.load);
      expect(again, isNot(same(sprites)));
    });

    testWidgets('forgets a load that never ends', (tester) async {
      await loadsWithin(tester, MapSprites.load);
      MapSprites.debugReset();
      startForever(MapSprites.load);
      await expectStalled(tester, MapSprites.load);

      MapSprites.debugReset();

      expect(await loadsWithin(tester, MapSprites.load), isNotNull);
    });
  });

  group('MapCreatureSheets', () {
    final sprite = livingCreatureSprites.first;

    testWidgets('forgets the sheets built', (tester) async {
      final sprites = await loadsWithin(tester, MapSprites.load);
      await loadsWithin(tester, () => MapCreatureSheets.preload(sprites!));
      expect(MapCreatureSheets.peek(sprite), isNotNull);

      MapCreatureSheets.debugReset();

      expect(MapCreatureSheets.peek(sprite), isNull);
    });

    testWidgets('forgets the builds that never end', (tester) async {
      final sprites = await loadsWithin(tester, MapSprites.load);
      Future<void> preload() => MapCreatureSheets.preload(sprites!);
      await loadsWithin(tester, preload);
      MapCreatureSheets.debugReset();
      startForever(preload);
      await expectStalled(tester, preload);

      MapCreatureSheets.debugReset();

      await loadsWithin(tester, preload);
      for (final path in livingCreatureSprites) {
        expect(MapCreatureSheets.peek(path), isNotNull, reason: path);
      }
    });
  });
}
