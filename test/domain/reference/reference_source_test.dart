import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/reference/reference_source.dart';
import 'package:abyss/domain/script/among_factions.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:flutter_test/flutter_test.dart';

String _noFile(String path) => throw StateError('no file read: $path');

void main() {
  test('reads back what it writes', () {
    const source = ReferenceSource(
      strategy: 'conquest',
      seed: 7,
      difficulty: Difficulty.hard,
      factions: [FactionPersonality.pearlOrder, FactionPersonality.anglerCult],
      turns: 120,
    );
    final json = source.toJson();

    expect(json, {
      'strategy': 'conquest',
      'seed': 7,
      'difficulty': 'hard',
      'factions': ['pearlOrder', 'anglerCult'],
      'turns': 120,
    });
    expect(ReferenceSource.fromJson(json).toJson(), json);
  });

  test('a scenario is named by its path, and has no strategy', () {
    const source = ReferenceSource(scenario: 'scenarios/x.json');

    expect(source.toJson(), {
      'scenario': 'scenarios/x.json',
      'seed': 1,
      'difficulty': 'normal',
      'factions': <String>[],
      'turns': 60,
    });
    expect(
      ReferenceSource.fromJson(source.toJson()).scenario,
      'scenarios/x.json',
    );
  });

  test('a strategy or a scenario, not both nor none', () {
    expect(() => ReferenceSource(), throwsA(isA<AssertionError>()));
    expect(
      () => ReferenceSource(strategy: 'idle', scenario: 'x.json'),
      throwsA(isA<AssertionError>()),
    );
  });

  test('a strategy is built by its name, without reading a file', () {
    final script = const ReferenceSource(strategy: 'conquest').script(_noFile);

    expect(script, isA<ConquestStrategy>());
    expect(
      () => const ReferenceSource(strategy: 'nope').script(_noFile),
      throwsFormatException,
    );
  });

  test('against factions the strategy plays among them', () {
    final script = const ReferenceSource(
      strategy: 'rush',
      factions: [FactionPersonality.magmaSmiths],
    ).script(_noFile);

    expect(script, isA<AmongFactions>());
    expect(script.factions, [FactionPersonality.magmaSmiths]);
    expect(script.playerName, 'rush');
  });

  test('a scenario is read from its file', () {
    final script = const ReferenceSource(scenario: 'a/b.json').script(
      (String path) =>
          path == 'a/b.json'
              ? '{"name": "mine", "otherwise": "economy", "turns": {}}'
              : _noFile(path),
    );

    expect(script, isA<TimelineScript>());
    expect(script.name, 'mine');
  });
}
