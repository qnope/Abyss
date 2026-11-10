import 'package:abyss/domain/reference/digest_rows.dart';
import 'package:abyss/domain/reference/reference_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rows = [
    ['a', 'b', 'c'],
    ['a', 'd', 'c'],
    ['e', 'd', 'c'],
    ['a', 'd', 'c'],
  ];

  group('DigestRows', () {
    test('a digest that did not change since the row before is "="', () {
      expect(DigestRows.compact(rows), [
        ['a', 'b', 'c'],
        ['=', 'd', '='],
        ['e', '=', '='],
        ['a', '=', '='],
      ]);
    });

    test('expand gives the rows back', () {
      expect(DigestRows.expand(DigestRows.compact(rows)), rows);
      expect(DigestRows.expand(const []), isEmpty);
      expect(DigestRows.compact(const []), isEmpty);
    });
  });

  group('ReferenceLayout', () {
    test('puts each item of an exploded container on its own line', () {
      const layout = ReferenceLayout({'', 'turns', 'journal.turns'});

      expect(
        layout.write({
          'format': 1,
          'source': {'seed': 3, 'factions': <String>[]},
          'turns': [
            {
              'turn': 1,
              'digests': ['a'],
            },
            {
              'turn': 2,
              'digests': ['='],
            },
          ],
          'journal': {
            'turns': {
              '1': [
                {'do': 'recruit', 'unit': 'scout'},
              ],
            },
          },
        }),
        '{\n'
        '"format":1,\n'
        '"source":{"seed":3,"factions":[]},\n'
        '"turns":[\n'
        '{"turn":1,"digests":["a"]},\n'
        '{"turn":2,"digests":["="]}\n'
        '],\n'
        '"journal":{"turns":{"1":[{"do":"recruit","unit":"scout"}]}}\n'
        '}\n',
      );
    });

    test('explodes a nested map only at its own path', () {
      const layout = ReferenceLayout({'', 'journal', 'journal.turns'});

      expect(
        layout.write({
          'journal': {
            'name': 'x',
            'turns': {'1': <Object?>[], '2': <Object?>[]},
          },
        }),
        '{\n"journal":{\n"name":"x",\n"turns":{\n"1":[],\n"2":[]\n}\n}\n}\n',
      );
    });

    test('keeps the keys in the order given, and empty containers short', () {
      const layout = ReferenceLayout({'', 'turns'});

      expect(
        layout.write({'b': 1, 'a': 2, 'turns': <Object?>[]}),
        '{\n"b":1,\n"a":2,\n"turns":[]\n}\n',
      );
    });

    test('writes a text already in JSON as it is', () {
      const layout = ReferenceLayout({''});

      expect(
        layout.write({'x': const RawJson('{"b":1,"a":"d:00"}')}),
        '{\n"x":{"b":1,"a":"d:00"}\n}\n',
      );
    });
  });
}
