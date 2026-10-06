import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';

void main() {
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
    }
    final again = await tester.runAsync(MapSprites.load);
    expect(identical(again, sprites), isTrue);
  });
}
