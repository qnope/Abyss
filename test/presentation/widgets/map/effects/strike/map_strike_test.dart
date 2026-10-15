import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strike_test_data.dart';

void main() {
  const lair = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 2);

  group('MapStrike.of', () {
    test('leads with the majority unit and counts the whole army', () {
      final strike = MapStrike.of(
        target: (3, 4),
        lair: lair,
        result: strikeResult(
            sent: {UnitType.scout: 2, UnitType.harpoonist: 3}),
      );
      expect(strike.target, (3, 4));
      expect(strike.lead, UnitType.harpoonist);
      expect(strike.count, 5);
      expect(strike.lairSprite, lair.svgPath);
      expect(strike.imagePaths, {UnitType.harpoonist.iconPath});
    });

    test('splits the damage dealt over the two lunges', () {
      final strike = MapStrike.of(
          target: (0, 0), lair: lair, result: strikeResult(damage: [7, 4]));
      expect(strike.hits, [6, 5]);
    });

    test('tells a victory from a defeat', () {
      expect(
        MapStrike.of(target: (0, 0), lair: lair, result: strikeResult())
            .victory,
        isTrue,
      );
      expect(
        MapStrike.of(
                target: (0, 0),
                lair: lair,
                result: strikeResult(victory: false))
            .victory,
        isFalse,
      );
    });
  });

  test('split shares a total between parts, the first ones larger', () {
    expect(MapStrike.split(11, 2), [6, 5]);
    expect(MapStrike.split(0, 2), [0, 0]);
    expect(MapStrike.split(7, 3), [3, 2, 2]);
  });
}
