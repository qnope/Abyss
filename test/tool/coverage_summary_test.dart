import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _script = '.github/scripts/coverage_summary.sh';

/// One lcov record for [file] with [found] lines, [hit] of them covered.
String _record(String file, int found, int hit) =>
    'SF:/repo/lib/$file\nLF:$found\nLH:$hit\nend_of_record\n';

/// Runs the summary script on [lcov] and returns its Markdown report.
String _summary(String lcov) {
  final dir = Directory.systemTemp.createTempSync('coverage_summary');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = File('${dir.path}/lcov.info')..writeAsStringSync(lcov);
  final result = Process.runSync('bash', [_script, file.path]);
  expect(result.exitCode, 0, reason: '${result.stderr}');
  return result.stdout as String;
}

void main() {
  test('counts the code written by hand', () {
    final report = _summary(_record('domain/game/game.dart', 10, 8));
    expect(report, contains('## Code coverage: 80.0%'));
    expect(report, contains('8 of 10 lines covered across 1 files.'));
  });

  test('leaves out the files generated for Hive', () {
    final report = _summary(_record('domain/game/game.dart', 10, 8) +
        _record('domain/game/game.g.dart', 10, 0));
    expect(report, contains('## Code coverage: 80.0%'));
    expect(report, isNot(contains('game.g.dart')));
  });

  test('leaves out the code generated from the ARB translations', () {
    final report = _summary(_record('domain/game/game.dart', 10, 8) +
        _record('presentation/l10n/app_localizations.dart', 10, 5) +
        _record('presentation/l10n/app_localizations_en.dart', 10, 0) +
        _record('presentation/l10n/app_localizations_es.dart', 10, 0));
    expect(report, contains('## Code coverage: 80.0%'));
    expect(report, isNot(contains('app_localizations')));
  });

  test('still counts the translation helpers written by hand', () {
    final report = _summary(_record('domain/game/game.dart', 10, 10) +
        _record('presentation/l10n/l10n_extension.dart', 10, 0));
    expect(report, contains('## Code coverage: 50.0%'));
    expect(report, contains('l10n_extension.dart'));
  });
}
