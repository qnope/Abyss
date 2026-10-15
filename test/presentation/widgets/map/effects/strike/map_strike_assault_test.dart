import 'package:abyss/domain/action/attack_base_defence.dart';
import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/action/base_damage.dart';
import 'package:abyss/domain/map/volcanic_kernel_placer.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../story/recording_canvas.dart';
import 'strike_test_data.dart';

const _base = 'assets/icons/map_content/player_base.svg';
const _volcano = 'assets/icons/terrain/volcanic_kernel.svg';
const _sent = {UnitType.scout: 1, UnitType.harpoonist: 4};

final _fight = strikeResult(taken: const [1, 2]).fight!;

AttackBaseResult _onBase({bool victory = true}) => AttackBaseResult.success(
      victory: victory,
      fight: _fight,
      sent: _sent,
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
      defence: const DefenceOutcome(engaged: {}, survivorsIntact: {},
          wounded: {}, dead: {}, initial: []),
      damage: const BaseDamage(rampartBefore: 1, rampartAfter: 1,
          headquartersBefore: 1, headquartersAfter: 1),
    );

AttackVolcanicKernelResult _onVolcano() => AttackVolcanicKernelResult.success(
      victory: true,
      captured: true,
      fight: _fight,
      sent: _sent,
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
    );

const _rounds = <StrikeRound>[(dealt: 7, taken: 1), (dealt: 4, taken: 2)];

void main() {
  test('an assault on a base plays its army and rounds on the place', () {
    final strike =
        MapStrike.onBase(target: (3, 4), sprite: _base, result: _onBase());
    expect((strike.target, strike.targetSprite), ((3, 4), _base));
    expect((strike.lead, strike.count), (UnitType.harpoonist, 5));
    expect(strike.rounds, _rounds);
    expect((strike.victory, strike.fades, strike.span), (true, false, 1));
    expect(MapStrike.onBase(target: (3, 4), sprite: _base,
        result: _onBase(victory: false)).victory, isFalse);
  });

  test('a held volcano assaulted as a base covers its cells', () {
    final strike = MapStrike.onBase(target: (3, 4), sprite: _volcano,
        result: _onBase(), span: VolcanicKernelPlacer.side);
    expect(strike.span, VolcanicKernelPlacer.side);
  });

  test('an assault on the volcano covers its cells and keeps it', () {
    final strike = MapStrike.onVolcano(
        target: (3, 4), sprite: _volcano, result: _onVolcano());
    expect((strike.target, strike.targetSprite), ((3, 4), _volcano));
    expect(strike.rounds, _rounds);
    expect((strike.victory, strike.fades), (true, false));
    expect(strike.span, VolcanicKernelPlacer.side);
  });

  testWidgets('the volcano flashes and glows over all its cells',
      (tester) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final strike = MapStrike.onVolcano(
        target: (5, 5), sprite: _volcano, result: _onVolcano());
    final run =
        strike.stage(MapStage(originOf: (_) => (0, 5), sprites: sprites));
    final area =
        const StrikeGeometry(origin: (0, 5), target: (5, 5), span: 2)
            .lairRect;
    const cyan = ColorFilter.mode(AbyssColors.biolumCyan, BlendMode.srcIn);
    final over = <(Rect, ColorFilter?)>[];
    for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 20) {
      final canvas = RecordingCanvas();
      run.paint(canvas, Duration(milliseconds: ms));
      for (final (i, (rect, _)) in canvas.images.indexed) {
        if (rect.overlaps(area)) over.add((rect, canvas.imageFilters[i]));
      }
    }
    final place = over.where((i) => i.$2 != null).toList();
    expect(place, isNotEmpty);
    for (final (rect, _) in place) {
      expect(rect, area);
    }
    expect(place.where((i) => i.$2 == cyan), isNotEmpty);
  });
}
