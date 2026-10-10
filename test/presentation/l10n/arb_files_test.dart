import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dir = 'lib/presentation/l10n';

Map<String, dynamic> _read(String locale) =>
    jsonDecode(File('$_dir/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messages(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

/// Names of the placeholders the French text of [key] declares.
Iterable<String> _placeholders(Map<String, dynamic> french, String key) {
  final meta = french['@$key'] as Map<String, dynamic>?;
  final placeholders = meta?['placeholders'] as Map<String, dynamic>?;
  return placeholders?.keys ?? const [];
}

void main() {
  final french = _read('fr');

  for (final locale in ['en', 'es']) {
    group('app_$locale.arb', () {
      final other = _read(locale);

      test('translates every French text and nothing more', () {
        expect(_messages(other), _messages(french));
      });

      test('declares its own locale', () {
        expect(other['@@locale'], locale);
      });

      test('keeps the placeholders of each French text', () {
        for (final key in _messages(french)) {
          for (final name in _placeholders(french, key)) {
            expect(other[key] as String, contains('{$name'), reason: key);
          }
        }
      });

      test('leaves no text empty', () {
        for (final key in _messages(other)) {
          expect((other[key] as String).trim(), isNotEmpty, reason: key);
        }
      });
    });
  }
}
