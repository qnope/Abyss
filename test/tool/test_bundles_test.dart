import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/test_bundles/test_bundles.dart';

/// A test folder holding [files], as paths relative to it.
Directory _testDir(List<String> files) {
  final dir = Directory.systemTemp.createTempSync('test_bundles');
  addTearDown(() => dir.deleteSync(recursive: true));
  for (final file in files) {
    File('${dir.path}/$file').createSync(recursive: true);
  }
  return dir;
}

void main() {
  group('findTestFiles', () {
    test('lists every test file under the folder, sorted', () {
      final dir = _testDir(['b_test.dart', 'a/z_test.dart', 'a/c_test.dart']);
      expect(findTestFiles(dir), [
        'a/c_test.dart',
        'a/z_test.dart',
        'b_test.dart',
      ]);
    });

    test('leaves out other files and the bundles themselves', () {
      final dir = _testDir([
        'a_test.dart',
        'helpers/h.dart',
        'helpers/h_test.dart',
        'bundles/bundle_0.dart',
        'bundles/old_test.dart',
      ]);
      expect(findTestFiles(dir), ['a_test.dart', 'helpers/h_test.dart']);
    });

    test('keeps only the files under the given paths', () {
      final dir = _testDir([
        'a/x_test.dart',
        'ab/y_test.dart',
        'b/z_test.dart',
      ]);
      expect(findTestFiles(dir, only: ['test/a', 'test/b/z_test.dart']), [
        'a/x_test.dart',
        'b/z_test.dart',
      ]);
    });

    test('takes the whole folder for the test folder itself', () {
      final dir = _testDir(['a/x_test.dart', 'b_test.dart']);
      expect(findTestFiles(dir, only: ['test/']), [
        'a/x_test.dart',
        'b_test.dart',
      ]);
    });
  });

  group('splitIntoBundles', () {
    final files = [for (var i = 0; i < 10; i++) 'f${i}_test.dart'];

    test('puts every file in exactly one bundle', () {
      final bundles = splitIntoBundles(files, 4);
      expect(bundles, hasLength(4));
      expect(bundles.expand((b) => b).toList()..sort(), files..sort());
    });

    test('keeps the files of a bundle in their given order', () {
      for (final bundle in splitIntoBundles(files, 3)) {
        expect(bundle, [...bundle]..sort());
      }
    });

    test('makes no empty bundle when files are few', () {
      expect(splitIntoBundles(['a_test.dart', 'b_test.dart'], 4), [
        ['a_test.dart'],
        ['b_test.dart'],
      ]);
      expect(splitIntoBundles([], 4), isEmpty);
    });

    test('balances the bundles by the cost of their files', () {
      final costs = {'f0_test.dart': 9.0, 'f1_test.dart': 5.0};
      final bundles = splitIntoBundles(files, 2, costs: costs);
      final sums = [
        for (final b in bundles) b.fold(0.0, (s, f) => s + (costs[f] ?? 1)),
      ];
      expect(sums, unorderedEquals([11.0, 11.0]));
    });

    test('gives the files left out of the costs the other cost', () {
      final costs = {'f0_test.dart': 4.5};
      final bundles = splitIntoBundles(files, 2, costs: costs, otherCost: 0.5);
      expect(bundles.map((b) => b.length), unorderedEquals([1, 9]));
    });
  });

  group('shuffleFiles', () {
    final files = [for (var i = 0; i < 20; i++) 'f${i}_test.dart'];

    test('mixes the files the same way for the same seed', () {
      expect(shuffleFiles(files, 7), shuffleFiles(files, 7));
      expect(shuffleFiles(files, 7), isNot(files));
      expect(shuffleFiles(files, 7).toList()..sort(), [...files]..sort());
    });

    test('reverses the files for a negative seed', () {
      expect(shuffleFiles(files, -1), files.reversed);
    });
  });

  group('renderBundle', () {
    final source = renderBundle(['a/x_test.dart', 'y_test.dart']);

    test('imports each file under its own prefix', () {
      expect(source, contains("import '../a/x_test.dart' as t0;"));
      expect(source, contains("import '../y_test.dart' as t1;"));
    });

    test('runs each file in a group named by its path, fresh', () {
      expect(source, contains("group('a/x_test.dart', () {"));
      expect(source, contains('setUpAll(resetProcessState);\n    t0.main();'));
      expect(source, contains("group('y_test.dart', () {"));
    });

    test('says it is generated and imports the reset', () {
      expect(source, startsWith('// GENERATED'));
      expect(source, contains("import '../helpers/fresh_process.dart';"));
      expect(
        source,
        contains("import 'package:flutter_test/flutter_test.dart';"),
      );
    });
  });
}
