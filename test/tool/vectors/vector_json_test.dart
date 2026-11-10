import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/vectors/vector_json.dart';

enum _Fish { swarm, hunter }

void main() {
  group('VectorJson.plain', () {
    test('keeps null, booleans, strings and small whole numbers', () {
      expect(VectorJson.plain(null), isNull);
      expect(VectorJson.plain(true), true);
      expect(VectorJson.plain('abc'), 'abc');
      expect(VectorJson.plain(-42), -42);
      expect(VectorJson.plain(9007199254740992), 9007199254740992);
    });

    test('writes a double as the hex digits of its bits, never a number', () {
      expect(VectorJson.plain(1.0), 'd:3ff0000000000000');
      expect(VectorJson.plain(-2.5), 'd:c004000000000000');
      expect(VectorJson.plain(0.1), 'd:3fb999999999999a');
      expect(VectorJson.plain(0.0), 'd:0000000000000000');
      expect(VectorJson.plain(-0.0), 'd:8000000000000000');
      expect(VectorJson.plain(double.infinity), 'd:7ff0000000000000');
      expect(VectorJson.plain(double.nan), 'd:7ff8000000000000');
      expect(VectorJson.plain(-double.nan), 'd:7ff8000000000000');
    });

    test('writes a whole number no double holds as its decimal digits', () {
      expect(VectorJson.plain(9007199254740993), 'i:9007199254740993');
      expect(VectorJson.plain(-9007199254740993), 'i:-9007199254740993');
      expect(
        VectorJson.plain(-9223372036854775808),
        'i:-9223372036854775808',
      );
    });

    test('names an enum value', () {
      expect(VectorJson.plain(_Fish.hunter), 'hunter');
    });

    test('goes through lists, sets and maps', () {
      expect(
        VectorJson.plain({
          _Fish.swarm: [1, 0.5, _Fish.hunter],
          7: {2, 3},
          'k': null,
        }),
        {
          'swarm': [1, 'd:3fe0000000000000', 'hunter'],
          '7': [2, 3],
          'k': null,
        },
      );
    });

    test('refuses what the format cannot hold', () {
      expect(() => VectorJson.plain(Object()), throwsArgumentError);
      expect(() => VectorJson.plain({1.5: 1}), throwsArgumentError);
      expect(() => VectorJson.plain({1: 'a', '1': 'b'}), throwsArgumentError);
      expect(() => VectorJson.plain('d:looks like bits'), throwsArgumentError);
      expect(() => VectorJson.plain('i:12'), throwsArgumentError);
    });
  });

  group('VectorJson.pairs', () {
    test('keeps the order of a map as a list of key and value', () {
      expect(VectorJson.pairs({_Fish.hunter: 2, _Fish.swarm: 1, null: 0}), [
        ['hunter', 2],
        ['swarm', 1],
        [null, 0],
      ]);
    });
  });

  group('VectorJson.encode', () {
    test('sorts the keys, whatever the order they were put in', () {
      final a = VectorJson.encode({'b': 1, 'a': 2, 'c': {'z': 1, 'y': 2}});
      final b = VectorJson.encode({'c': {'y': 2, 'z': 1}, 'a': 2, 'b': 1});
      expect(a, b);
      expect(a.indexOf('"a"'), lessThan(a.indexOf('"b"')));
      expect(a.indexOf('"y"'), lessThan(a.indexOf('"z"')));
    });

    test('is JSON that reads back as the plain value', () {
      final value = {
        'name': 'é"\\\n',
        'list': [1, -2, true, null, 1.5, <int>[], <String, int>{}],
        'deep': {
          'a': [
            {'x': 1},
          ],
        },
      };
      expect(
        jsonDecode(VectorJson.encode(value)),
        VectorJson.plain(value),
      );
    });

    test('spreads the first levels, one line each below', () {
      expect(
        VectorJson.encode({
          'cases': [
            {'in': 1, 'out': [1, 2]},
            {'in': 2, 'out': <int>[]},
          ],
          'name': 'n',
        }, inlineFrom: 2),
        '{\n'
        ' "cases": [\n'
        '  {"in":1,"out":[1,2]},\n'
        '  {"in":2,"out":[]}\n'
        ' ],\n'
        ' "name": "n"\n'
        '}\n',
      );
    });
  });
}
