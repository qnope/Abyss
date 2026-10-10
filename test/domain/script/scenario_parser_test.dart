import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScenarioParser', () {
    test('reads the name, the timeline and the fallback strategy', () {
      final script = ScenarioParser.parse('''
        {
          "name": "rush",
          "otherwise": "economy",
          "turns": {
            "1": [{"do": "upgrade", "building": "headquarters"}],
            "2": []
          }
        }
      ''');

      expect(script.name, 'rush');
      expect(script.turns.keys, <int>[1, 2]);
      expect(script.turns[1], hasLength(1));
      expect(script.otherwise, isA<EconomyStrategy>());
    });

    test('plays a scenario end to end', () {
      final script = ScenarioParser.parse('''
        {"turns": {"1": [{"do": "upgrade", "building": "headquarters"}]}}
      ''');

      final report = ScriptRunner(maxTurns: 2).run(script, seed: 3);

      expect(report.scriptName, 'scenario');
      expect(report.buildings[BuildingType.headquarters], 1);
    });

    test('pins the difficulty it names, by its Dart name', () {
      expect(ScenarioParser.parse('{"difficulty": "hard"}').difficulty,
          Difficulty.hard);
      expect(ScenarioParser.parse('{}').difficulty, isNull);
      expect(() => ScenarioParser.parse('{"difficulty": "nightmare"}'),
          throwsFormatException);
    });

    test('rejects a malformed scenario', () {
      expect(() => ScenarioParser.parse('[]'), throwsFormatException);
      expect(
        () => ScenarioParser.parse('{"turns": {"zero": []}}'),
        throwsFormatException,
      );
      expect(
        () => ScenarioParser.parse('{"otherwise": "magic"}'),
        throwsFormatException,
      );
    });
  });
}
