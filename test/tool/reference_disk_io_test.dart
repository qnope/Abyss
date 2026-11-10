import 'dart:io';

import 'package:abyss/domain/reference/reference_cli.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/reference/disk_io.dart';
import '../../tool/reference/sha256_hex.dart';

void main() {
  late Directory dir;
  late List<String> log;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('reference_disk_io');
    addTearDown(() => dir.deleteSync(recursive: true));
    log = <String>[];
  });

  int run(List<String> args) =>
      ReferenceCli(digest: sha256Hex, io: diskIo(log: log.add)).run(args);

  test('writes a file, in a folder it makes when missing, and reads it', () {
    final io = diskIo(log: log.add);

    io.write('${dir.path}/new/a.json', '{"é":1}\n');

    expect(io.read('${dir.path}/new/a.json'), '{"é":1}\n');
    expect(File('${dir.path}/new/a.json').readAsBytesSync(), [
      ...'{"'.codeUnits,
      0xc3,
      0xa9,
      ...'":1}\n'.codeUnits,
    ]);
  });

  test('lists the JSON files of a folder by name, sorted, nothing else', () {
    final io = diskIo(log: log.add);
    for (final String name in ['b.json', 'a.json', 'notes.md']) {
      io.write('${dir.path}/$name', '');
    }
    Directory('${dir.path}/folder.json').createSync();

    expect(io.list(dir.path), ['a.json', 'b.json']);
  });

  test('makes a new temporary folder each time', () {
    final io = diskIo(log: log.add);
    final String first = io.temporaryFolder();
    final String second = io.temporaryFolder();
    addTearDown(() => Directory(first).deleteSync());
    addTearDown(() => Directory(second).deleteSync());

    expect(first, isNot(second));
    expect(Directory(first).existsSync(), isTrue);
  });

  test('the tool exports to the disk, then checks what it finds there', () {
    final String file = '${dir.path}/idle.json';
    run(['--strategy', 'idle', '--turns', '2', '--out', file]);

    expect(run(['--check', dir.path]), 0);

    final String committed = File(file).readAsStringSync();
    File(
      file,
    ).writeAsStringSync(committed.replaceFirst('"turn":3', '"turn":4'));
    log.clear();

    expect(run(['--check', dir.path]), 1);
    expect(log.first, 'differs: $file');
    final String into =
        RegExp(r'regenerated in (\S+)\.').firstMatch(log.last)![1]!;
    addTearDown(() => Directory(into).deleteSync(recursive: true));
    expect(File('$into/idle.json').readAsStringSync(), committed);
  });
}
