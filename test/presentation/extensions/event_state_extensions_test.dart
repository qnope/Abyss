import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/presentation/extensions/event_state_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('counts the current turn among the turns left', () {
    expect(turnsLeft(13, 10), 4);
    expect(turnsLeft(13, 13), 1);
  });

  test('a countdown reads in the singular on its last turn', () {
    expect(countdownText(fr, 'Tempête', 2), 'Tempête : encore 2 tours');
    expect(countdownText(fr, 'Tempête', 1), 'Tempête : encore 1 tour');
  });

  test('a countdown reads in English and Spanish', () {
    expect(countdownText(en, 'Storm', 2), 'Storm: 2 turns left');
    expect(countdownText(en, 'Storm', 1), 'Storm: 1 turn left');
    expect(countdownText(es, 'Tormenta', 2), 'Tormenta: quedan 2 turnos');
    expect(countdownText(es, 'Tormenta', 1), 'Tormenta: queda 1 turno');
  });

  group('wreckCountdownAt', () {
    final state = EventState(
      wreckPosition: GridPosition(x: 2, y: 3),
      wreckUntilTurn: 13,
    );

    test('counts down on the wreck cell of level 1', () {
      expect(
          state.wreckCountdownAt(fr, 2, 3, 1, 11), 'Épave : encore 3 tours');
      expect(state.wreckCountdownAt(en, 2, 3, 1, 11), 'Wreck: 3 turns left');
    });

    test('says nothing elsewhere or without a wreck', () {
      expect(state.wreckCountdownAt(fr, 3, 2, 1, 11), isNull);
      expect(state.wreckCountdownAt(fr, 2, 3, 2, 11), isNull);
      expect(EventState().wreckCountdownAt(fr, 2, 3, 1, 11), isNull);
    });
  });

  group('effectCountdown', () {
    test('says the greenhouses are heated during a cold current', () {
      final state = EventState(
        active: RandomEventType.coldCurrent,
        activeUntilTurn: 12,
        heating: true,
      );
      expect(state.effectCountdown(fr, 11),
          'Courant froid (serres chauffées) : encore 2 tours');
      expect(state.effectCountdown(en, 11),
          'Cold Current (heated greenhouses): 2 turns left');
    });
  });
}
