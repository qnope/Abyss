import 'package:abyss/domain/reference/canonical_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String write(Object? value) => CanonicalWriter.write(value);

  group('scalars', () {
    test('null, booleans and integers are written as JSON does', () {
      expect(write(null), 'null');
      expect(write(true), 'true');
      expect(write(false), 'false');
      expect(write(0), '0');
      expect(write(-42), '-42');
      expect(write(9007199254740993), '9007199254740993');
      expect(write(-9223372036854775808), '-9223372036854775808');
    });

    test('a double is the string d: and the hex of its IEEE-754 bits', () {
      expect(write(1.0), '"d:3ff0000000000000"');
      expect(write(0.1), '"d:3fb999999999999a"');
      expect(write(-2.5), '"d:c004000000000000"');
      expect(write(5e-324), '"d:0000000000000001"');
    });

    test('negative zero keeps its sign', () {
      expect(write(0.0), '"d:0000000000000000"');
      expect(write(-0.0), '"d:8000000000000000"');
    });

    test('infinities are written', () {
      expect(write(double.infinity), '"d:7ff0000000000000"');
      expect(write(double.negativeInfinity), '"d:fff0000000000000"');
    });

    test('NaN fails loudly: it has many bit patterns', () {
      expect(() => write(double.nan), throwsArgumentError);
      expect(() => write(<Object?>[1, double.nan]), throwsArgumentError);
    });
  });

  group('strings', () {
    test('only the quote, the backslash and control characters escape', () {
      expect(write('abc'), '"abc"');
      expect(write('a"b'), r'"a\"b"');
      expect(write(r'a\b'), r'"a\\b"');
      expect(write('a\nb\tc'), r'"a\u000ab\u0009c"');
      expect(write('\u0000\u001f'), r'"\u0000\u001f"');
    });

    test('everything else is raw: slash, DEL, accents, emoji', () {
      expect(write('a/b'), '"a/b"');
      expect(write('\u007f'), '"\u007f"');
      expect(write('Léviathan'), '"Léviathan"');
      expect(write('\u{1F419}'), '"\u{1F419}"');
      expect(write(' '), '" "');
    });
  });

  group('collections', () {
    test('a list keeps its order, without whitespace', () {
      expect(write(<Object?>[3, 1, 2]), '[3,1,2]');
      expect(write(<Object?>[]), '[]');
      expect(write(<Object?>[<Object?>[], null]), '[[],null]');
    });

    test('map keys are sorted, whatever the order they were added in', () {
      expect(
        write(<String, Object?>{'b': 1, 'a': 2, 'c': <String, Object?>{}}),
        '{"a":2,"b":1,"c":{}}',
      );
    });

    test('keys are sorted by UTF-16 code unit, not by letter', () {
      // "Z" (0x5a) < "a" (0x61) < "é" (0xe9) < the surrogates of an
      // emoji (0xd83d) < "￿": a code point order would put the
      // emoji last.
      expect(
        write(<String, Object?>{
          '￿': 5,
          '\u{1F419}': 4,
          'é': 3,
          'a': 2,
          'Z': 1,
          'aa': 6,
          '': 0,
        }),
        '{"":0,"Z":1,"a":2,"aa":6,"é":3,"\u{1F419}":4,"￿":5}',
      );
    });

    test('keys are escaped like any string', () {
      expect(write(<String, Object?>{'a"b': 1}), r'{"a\"b":1}');
    });

    test('nests', () {
      expect(
        write(<String, Object?>{
          'list': <Object?>[
            <String, Object?>{'y': 2, 'x': 1},
            'e',
          ],
          'd': 0.5,
        }),
        '{"d":"d:3fe0000000000000","list":[{"x":1,"y":2},"e"]}',
      );
    });
  });

  group('anything else fails loudly', () {
    test('an enum, a set, a date, a map with other keys', () {
      expect(() => write(DateTime(2020)), throwsArgumentError);
      expect(() => write(<int>{1}), throwsArgumentError);
      expect(() => write(<int, int>{1: 1}), throwsArgumentError);
      expect(() => write(Duration.zero), throwsArgumentError);
    });
  });
}
