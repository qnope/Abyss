import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/widgets/map/decor/decor_kind.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';

void main() {
  test('lists the floor tiles of every terrain', () {
    for (final terrain in TerrainType.values) {
      expect(MapSprites.svgPaths, containsAll(terrain.tileSvgPaths));
    }
  });

  test('lists every decor standing between the cells', () {
    expect(MapSprites.svgPaths,
        containsAll(SeabedDecor.all.map((kind) => kind.svgPath)));
  });

  testWidgets('rasterizes every map sprite once', (tester) async {
    final sprites = await tester.runAsync(MapSprites.load);
    expect(sprites, isNotNull);
    for (final path in MapSprites.svgPaths) {
      final image = sprites!.svg(path);
      expect(image, isNotNull, reason: path);
      expect(image!.width, MapSprites.spriteSize);
    }
    for (final glow in MapGlow.values.where((g) => g != MapGlow.none)) {
      expect(sprites!.glow(glow), isNotNull, reason: glow.name);
      expect(sprites.pool(glow), isNotNull, reason: glow.name);
    }
    expect(sprites!.shadow.width, greaterThan(0));
    // The floor's tiles, decor and shadow, in one bitmap.
    final floor = sprites.floor;
    for (final path in [
      for (final terrain in TerrainType.values) ...terrain.tileSvgPaths,
      for (final kind in SeabedDecor.all) kind.svgPath,
    ]) {
      expect(floor.rectOf(path)?.width, MapSprites.spriteSize, reason: path);
    }
    expect(floor.rectOf(MapSprites.shadowSprite)?.width, sprites.shadow.width);
    final again = await tester.runAsync(MapSprites.load);
    expect(identical(again, sprites), isTrue);
  });
}
