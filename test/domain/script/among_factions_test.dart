import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/script/among_factions.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plays the script it wraps, against the given factions', () {
    final script = AmongFactions(const ConquestStrategy(), const [
      FactionPersonality.pearlOrder,
      FactionPersonality.anglerCult,
    ]);
    expect(script.factions, hasLength(2));
    expect(script.name, 'conquest+2');
    expect(script.factionsPlay, isTrue);
  });

  test('draws the factions from the catalogue, without duplicates', () {
    final script = AmongFactions.drawn(const IdleScript(), 5, seed: 3);
    expect(script.factions.toSet(), hasLength(5));
  });

  test('a game against factions runs and the report says who won', () {
    final report = ScriptRunner(
      maxTurns: 10,
    ).run(AmongFactions.drawn(const ConquestStrategy(), 3, seed: 1), seed: 1);
    expect(report.turnsPlayed, 10);
    expect(report.factionWon, isFalse);
  });
}
