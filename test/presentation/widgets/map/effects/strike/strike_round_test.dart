import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strike_test_data.dart';

void main() {
  test('one round per turn of the fight, with what both sides lost', () {
    final fight = strikeResult(damage: [7, 4], taken: [1, 3]).fight;
    expect(roundsOf(fight), const <StrikeRound>[
      (dealt: 7, taken: 1),
      (dealt: 4, taken: 3),
    ]);
  });

  test('no fight, no round', () {
    expect(roundsOf(null), isEmpty);
  });
}
