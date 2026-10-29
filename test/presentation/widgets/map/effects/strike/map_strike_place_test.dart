import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../story/recording_canvas.dart';
import 'strike_test_data.dart';

const _sprite = 'assets/icons/posts/faille_guarded.svg';

AttackTransitionBaseResult _assault({bool victory = true}) =>
    AttackTransitionBaseResult.success(
      victory: victory,
      captured: victory,
      fight: strikeResult(victory: victory, taken: const [1, 2]).fight,
      sent: const {UnitType.scout: 1, UnitType.domeBreaker: 4},
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
    );

MapStrike _strike({bool victory = true}) => MapStrike.onPlace(
    target: (5, 5), sprite: _sprite, result: _assault(victory: victory));

void main() {
  group('MapStrike.onPlace', () {
    test('plays the assault with the army and the place drawn there', () {
      final strike = MapStrike.onPlace(
          target: (3, 4), sprite: _sprite, result: _assault());
      expect(strike.target, (3, 4));
      expect(strike.lead, UnitType.domeBreaker);
      expect(strike.count, 5);
      expect(strike.targetSprite, _sprite);
      expect(strike.rounds, const <StrikeRound>[
        (dealt: 7, taken: 1),
        (dealt: 4, taken: 2),
      ]);
      expect(strike.victory, isTrue);
      expect(strike.fades, isFalse);
    });

    test('tells a defeat, while a beaten monster still fades', () {
      expect(_strike(victory: false).victory, isFalse);
      const lair =
          MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 1);
      expect(
          MapStrike.of(target: (0, 0), lair: lair, result: strikeResult())
              .fades,
          isTrue);
    });
  });

  group('a place assaulted on the map', () {
    final place = MapProjection.standingOf((5, 5));
    const cyan = ColorFilter.mode(AbyssColors.biolumCyan, BlendMode.srcIn);

    /// Every image the assault draws centred on the place, with its
    /// paint's colour and filter.
    Future<List<(Rect, Color, ColorFilter?)>> drawn(
        WidgetTester tester, {required bool victory}) async {
      final sprites = await tester.runAsync(MapSprites.load);
      final run = _strike(victory: victory)
          .stage(MapStage(originOf: (_) => (0, 5), sprites: sprites));
      final images = <(Rect, Color, ColorFilter?)>[];
      for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 20) {
        final canvas = RecordingCanvas();
        run.paint(canvas, Duration(milliseconds: ms));
        for (final (i, (rect, color)) in canvas.images.indexed) {
          if ((rect.center - place.center).distance < 1) {
            images.add((rect, color, canvas.imageFilters[i]));
          }
        }
      }
      return images;
    }

    testWidgets('a victory neither shrinks nor fades the place: it lights '
        'it up in cyan', (tester) async {
      final images = await drawn(tester, victory: true);
      for (final (rect, _, filter) in images) {
        expect(rect, place);
        expect(filter, isNotNull);
      }
      expect(images.where((i) => i.$3 == cyan && i.$2.a > 0.5), isNotEmpty);
    });

    testWidgets('a defeat only flashes the place as hits land',
        (tester) async {
      final images = await drawn(tester, victory: false);
      expect(images, isNotEmpty);
      for (final (rect, _, filter) in images) {
        expect(rect, place);
        expect(filter, isNotNull);
        expect(filter, isNot(cyan));
      }
    });
  });
}
