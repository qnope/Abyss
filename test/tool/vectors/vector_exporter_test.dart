import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/vectors/vector_exporter.dart';
import '../../../tool/vectors/vector_file.dart';

Directory _folder() {
  final dir = Directory.systemTemp.createTempSync('vector_exporter');
  addTearDown(() => dir.deleteSync(recursive: true));
  return dir;
}

VectorFile _file(String name, List<Object?> cases) => VectorFile(name, {
  'halves': VectorSection('half(x)', () => cases),
});

void main() {
  final exporter = VectorExporter([
    _file('one', [
      {'x': 3, 'out': 1.5},
    ]),
    _file('two', const []),
  ]);

  group('VectorFile.render', () {
    test('gives the name, the API and the cases of each section', () {
      expect(jsonDecode(exporter.files.first.render()), {
        'name': 'one',
        'api': {'halves': 'half(x)'},
        'sections': {
          'halves': [
            {'x': 3, 'out': 'd:3ff8000000000000'},
          ],
        },
      });
    });
  });

  group('VectorExporter', () {
    test('writes one file per vector, in a folder it creates', () {
      final dir = Directory('${_folder().path}/deep/vectors');
      exporter.writeTo(dir);
      expect(
        File('${dir.path}/one.json').readAsStringSync(),
        exporter.files.first.render(),
      );
      expect(File('${dir.path}/two.json').existsSync(), isTrue);
    });

    test('finds nothing stale in what it just wrote', () {
      final dir = _folder();
      exporter.writeTo(dir);
      expect(exporter.staleIn(dir), isEmpty);
    });

    test('names the files changed, missing or no longer generated', () {
      final dir = _folder();
      exporter.writeTo(dir);
      File('${dir.path}/two.json').writeAsStringSync('{}');
      File('${dir.path}/one.json').deleteSync();
      File('${dir.path}/zombie.json').writeAsStringSync('{}');
      File('${dir.path}/README.md').writeAsStringSync('kept');
      expect(exporter.staleIn(dir), ['one.json', 'two.json', 'zombie.json']);
    });

    test('removes the vectors no longer generated, nothing else', () {
      final dir = _folder();
      File('${dir.path}/zombie.json').writeAsStringSync('{}');
      File('${dir.path}/README.md').writeAsStringSync('kept');
      exporter.writeTo(dir);
      expect(File('${dir.path}/zombie.json').existsSync(), isFalse);
      expect(File('${dir.path}/README.md').readAsStringSync(), 'kept');
    });
  });
}
