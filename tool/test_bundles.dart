// Writes the test bundles `tool/test.sh` runs, from the repository root:
//   dart run tool/test_bundles.dart [--bundles=4] [--seed=N] [test/path ...]
// --seed mixes the files in another order (a negative one reverses them),
// to show a test relying on the files run before it.
import 'dart:io';

import 'test_bundles/slow_tests.dart';
import 'test_bundles/test_bundles.dart';

void main(List<String> args) {
  var count = 4;
  int? seed;
  final paths = <String>[];
  for (final arg in args) {
    if (arg.startsWith('--bundles=')) {
      count = _number(arg);
    } else if (arg.startsWith('--seed=')) {
      seed = _number(arg);
    } else if (arg.startsWith('-')) {
      _fail('Unknown option $arg.');
    } else {
      paths.add(arg);
    }
  }
  if (count < 1) _fail('--bundles takes 1 or more.');
  var files = findTestFiles(Directory('test'), only: paths);
  if (files.isEmpty) _fail('No test file under ${paths.join(' ')}.');
  if (seed != null) files = shuffleFiles(files, seed);
  final out = Directory('test/$bundlesFolder');
  if (out.existsSync()) out.deleteSync(recursive: true);
  out.createSync(recursive: true);
  final bundles = splitIntoBundles(
    files,
    count,
    costs: slowTestSeconds,
    otherCost: otherTestSeconds,
  );
  for (var i = 0; i < bundles.length; i++) {
    File(
      '${out.path}/bundle_$i.dart',
    ).writeAsStringSync(renderBundle(bundles[i]));
  }
  stdout.writeln(
    'Wrote ${bundles.length} bundles of ${files.length} test files.',
  );
}

/// The whole number after the `=` of [option], or a usage error.
int _number(String option) {
  final number = int.tryParse(option.substring(option.indexOf('=') + 1));
  if (number == null) _fail('$option takes a whole number.');
  return number;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
