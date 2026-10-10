import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/presentation/extensions/event_state_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts the current turn among the turns left', () {
    expect(turnsLeft(13, 10), 4);
    expect(turnsLeft(13, 13), 1);
  });

  test('a countdown reads in the singular on its last turn', () {
    expect(countdownText('Tempête', 2), 'Tempête : encore 2 tours');
    expect(countdownText('Tempête', 1), 'Tempête : encore 1 tour');
  });

  group('wreckCountdownAt', () {
    final state = EventState(
      wreckPosition: GridPosition(x: 2, y: 3),
      wreckUntilTurn: 13,
    );

    test('counts down on the wreck cell of level 1', () {
      expect(state.wreckCountdownAt(2, 3, 1, 11), 'Épave : encore 3 tours');
    });

    test('says nothing elsewhere or without a wreck', () {
      expect(state.wreckCountdownAt(3, 2, 1, 11), isNull);
      expect(state.wreckCountdownAt(2, 3, 2, 11), isNull);
      expect(EventState().wreckCountdownAt(2, 3, 1, 11), isNull);
    });
  });
}
