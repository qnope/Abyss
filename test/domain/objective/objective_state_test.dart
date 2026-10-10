import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObjectiveState', () {
    test('starts with nothing completed, the tutorial and tips off', () {
      final state = ObjectiveState();

      expect(state.completed, isEmpty);
      expect(state.tutorialEnabled, isFalse);
      expect(state.tipsEnabled, isFalse);
      expect(state.isCompleted(ObjectiveId.hqLevel1), isFalse);
      expect(state.seenTips, isEmpty);
    });

    test('keeps the tips seen in their order, each once', () {
      final state = ObjectiveState()
        ..markSeen(TipId.lair)
        ..markSeen(TipId.noiseGauge)
        ..markSeen(TipId.lair);

      expect(state.seenTips, [TipId.lair, TipId.noiseGauge]);
      expect(state.hasSeen(TipId.noiseGauge), isTrue);
      expect(state.hasSeen(TipId.descent), isFalse);
    });

    test('keeps the completions in their order, each once', () {
      final state = ObjectiveState(tutorialEnabled: true)
        ..complete(ObjectiveId.mines)
        ..complete(ObjectiveId.hqLevel1)
        ..complete(ObjectiveId.mines);

      expect(state.completed, [ObjectiveId.mines, ObjectiveId.hqLevel1]);
      expect(state.isCompleted(ObjectiveId.hqLevel1), isTrue);
      expect(state.tutorialEnabled, isTrue);
    });

    test('a new player carries an empty state', () {
      final state = Player(name: 'Nemo').savedObjectiveState;

      expect(state, isNotNull);
      expect(state!.completed, isEmpty);
      expect(state.tutorialEnabled, isFalse);
    });
  });
}
