import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _script = '.github/scripts/coverage_summary.sh';

/// One lcov record for [file] with [found] lines, [hit] of them covered.
String _record(String file, int found, int hit) =>
    'SF:/repo/lib/$file\nLF:$found\nLH:$hit\nend_of_record\n';

/// Runs the summary script on [lcov], with [minimum] as the coverage
/// threshold when given.
ProcessResult _run(String lcov, {String? minimum}) {
  final dir = Directory.systemTemp.createTempSync('coverage_summary');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = File('${dir.path}/lcov.info')..writeAsStringSync(lcov);
  return Process.runSync('bash', [_script, file.path],
      environment: {'COVERAGE_MIN': minimum ?? ''});
}

/// Runs the summary script on [lcov] and returns its Markdown report.
String _summary(String lcov) {
  final result = _run(lcov);
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

  group('with a minimum coverage', () {
    final lcov = _record('domain/game/game.dart', 1000, 970);

    test('passes when the coverage reaches it', () {
      expect(_run(lcov, minimum: '97').exitCode, 0);
    });

    test('fails and says why when the coverage is below it', () {
      final result = _run(lcov, minimum: '97.5');
      expect(result.exitCode, 1);
      expect(result.stderr, contains('97.00% is below the 97.5% minimum'));
    });

    test('still writes the report when it fails', () {
      final result = _run(lcov, minimum: '98');
      expect(result.stdout, contains('## Code coverage: 97.0%'));
    });
  });
}
