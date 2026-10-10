import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/event_tips.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
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

    test('files each tip in its section of the Guide', () {
      expect(TipCatalog.byId(TipId.noiseGauge).category, TipCategory.base);
      expect(TipCatalog.byId(TipId.lastChance).category, TipCategory.threats);
      expect(TipCatalog.byId(TipId.descent).category, TipCategory.map);
      expect(TipCatalog.byId(TipId.storm).category, TipCategory.events);
    });

    test('one tip per event, in the events section', () {
      final ids = RandomEventType.values.map(EventTips.idOf).toSet();
      expect(ids, hasLength(RandomEventType.values.length));
      for (final id in ids) {
        expect(TipCatalog.byId(id).category, TipCategory.events);
      }
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
