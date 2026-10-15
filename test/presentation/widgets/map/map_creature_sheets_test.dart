import 'package:abyss/presentation/widgets/ambience/creature_sheet.dart';
import 'package:abyss/presentation/widgets/map/living_creatures.dart';
import 'package:abyss/presentation/widgets/map/map_creature_sheets.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds the sheet of every living creature once',
      (tester) async {
    final sprite = livingCreatureSprites.first;
    expect(MapCreatureSheets.peek(sprite), isNull);
    final sprites = await tester.runAsync(MapSprites.load);
    final watch = Stopwatch()..start();
    await tester.runAsync(() => MapCreatureSheets.preload(sprites!));
    // ignore: avoid_print
    print('Creature sheets built in ${watch.elapsedMilliseconds} ms');
    for (final path in livingCreatureSprites) {
      final sheet = MapCreatureSheets.peek(path);
      expect(sheet, isNotNull, reason: path);
      expect(sheet!.atlas.width, CreatureSheet.columns * CreatureSheet.pixels);
    }
    final first = MapCreatureSheets.peek(sprite);
    await tester.runAsync(() => MapCreatureSheets.preload(sprites!));
    expect(identical(MapCreatureSheets.peek(sprite), first), isTrue);
  });
}
