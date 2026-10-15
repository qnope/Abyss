import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
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
      expect(strike.targetSprite, lair.svgPath);
      expect(strike.imagePaths, {UnitType.harpoonist.iconPath});
    });

    test('plays one round per turn, with what both sides lost', () {
      final strike = MapStrike.of(
        target: (0, 0),
        lair: lair,
        result: strikeResult(damage: [7, 4, 0, 9, 2], taken: [1, 0, 3, 2, 5]),
      );
      expect(strike.rounds, const <StrikeRound>[
        (dealt: 7, taken: 1),
        (dealt: 4, taken: 0),
        (dealt: 0, taken: 3),
        (dealt: 9, taken: 2),
        (dealt: 2, taken: 5),
      ]);
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
}
