import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 8);

  test('addNoise fills the gauge and the total', () {
    final state = RaidState()..addNoise(5)..addNoise(3);
    expect(state.noise, 8);
    expect(state.totalNoise, 8);
  });

  test('addNoise ignores non-positive amounts', () {
    final state = RaidState()..addNoise(0)..addNoise(-4);
    expect(state.totalNoise, 0);
  });

  test('announce empties the gauge but keeps the total', () {
    final state = RaidState()..addNoise(42);
    state.announce(wave, 12);
    expect(state.noise, 0);
    expect(state.totalNoise, 42);
    expect(state.isIncoming, isTrue);
    expect(state.arrivalTurn, 12);
  });

  test('clearIncoming forgets the announced raid', () {
    final state = RaidState()..announce(wave, 12);
    state.clearIncoming();
    expect(state.isIncoming, isFalse);
    expect(state.arrivalTurn, isNull);
  });
}
