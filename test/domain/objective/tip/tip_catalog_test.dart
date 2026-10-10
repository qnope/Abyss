import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/event_tips.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/objective_helpers.dart';

void main() {
  late Game game;
  ObjectiveState state() => game.humanPlayer.savedObjectiveState!;
  TipId? next() => TipCatalog.nextFor(game, game.humanPlayer)?.id;

  setUp(() {
    game = objectiveGame();
    game.humanPlayer.savedObjectiveState = ObjectiveState(tipsEnabled: true);
  });

  group('TipCatalog', () {
    test('holds one tip per id, in the order of the ids', () {
      expect(TipCatalog.all.map((tip) => tip.id), TipId.values);
    });

    test('names the buildings as the base shows them', () {
      String text(TipId id) => TipCatalog.byId(id).lines.join(' ');
      expect(
        text(TipId.raidAnnounced),
        contains(BuildingType.coralCitadel.displayName),
      );
      expect(
        text(TipId.descent),
        contains(BuildingType.descentModule.displayName),
      );
    });

    test('every tip has a title and 2 or 3 short lines', () {
      for (final tip in TipCatalog.all) {
        expect(tip.title, isNotEmpty, reason: tip.id.name);
        expect(tip.lines.length, inInclusiveRange(2, 3), reason: tip.id.name);
        for (final line in tip.lines) {
          expect(line.length, lessThanOrEqualTo(120), reason: line);
        }
      }
    });

    test('one tip per event, titled after it', () {
      final ids = RandomEventType.values.map(EventTips.idOf).toSet();
      expect(ids, hasLength(RandomEventType.values.length));
      expect(
        TipCatalog.byId(EventTips.idOf(RandomEventType.wreck)).title,
        'Épave',
      );
    });
  });

  group('TipCatalog.nextFor', () {
    test('none while no situation calls for a tip', () {
      expect(next(), isNull);
    });

    test('the tip whose situation is there', () {
      game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4);
      expect(next(), TipId.noiseGauge);
    });

    test('the first one in catalog order when several apply', () {
      game.humanPlayer.eventState.recordDraw(RandomEventType.storm);
      game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4);
      expect(next(), TipId.noiseGauge);
    });

    test('skips the tips already seen', () {
      game.humanPlayer.eventState.recordDraw(RandomEventType.storm);
      game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4);
      state().markSeen(TipId.noiseGauge);
      expect(next(), TipId.events);
      state().markSeen(TipId.events);
      expect(next(), EventTips.idOf(RandomEventType.storm));
      state().markSeen(EventTips.idOf(RandomEventType.storm));
      expect(next(), isNull);
    });

    test('none when the tips are switched off', () {
      game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4);
      state().tipsEnabled = false;
      expect(next(), isNull);
    });
  });
}
