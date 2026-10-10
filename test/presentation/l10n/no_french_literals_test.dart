import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files allowed to hold accented literals that are not texts: the
/// glyphs rasterized ahead of time.
const _allowed = {'lib/presentation/widgets/warm_up/game_warm_up.dart'};

const _accents = '[éèêàçùôîûœÉÈÀÇ]';

/// A single- or double-quoted literal holding a French accent.
final _accentedLiteral = RegExp(
  "'[^'\\n]*$_accents[^'\\n]*'|\"[^\"\\n]*$_accents[^\"\\n]*\"",
);

void main() {
  test('screens read their texts from the translations', () {
    final offenders = <String>[];
    final files = Directory('lib/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.contains('/l10n/'))
        .where((file) => !_allowed.contains(file.path));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('//')) continue;
        if (_accentedLiteral.hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
