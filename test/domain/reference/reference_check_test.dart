import 'package:flutter_test/flutter_test.dart';

import 'memory_disk.dart';

const _game = ['--strategy', 'economy', '--seed', '2', '--turns', '6'];

void main() {
  group('the committed set', () {
    MemoryDisk committed() =>
        MemoryDisk()
          ..run([..._game, '--out', 'reference/games/a.json'])
          ..run([
            '--strategy',
            'idle',
            '--turns',
            '3',
            '--out',
            'reference/games/b.json',
          ])
          ..files['reference/games/notes.txt'] = 'not a game'
          ..log.clear();

    test('--check passes when every game plays the same again', () {
      final disk = committed();

      expect(disk.run(['--check']), 0);
      expect(disk.log, ['2 reference games up to date in reference/games']);
      expect(disk.files, hasLength(3));
    });

    test('--check fails, names the files that differ and writes what '
        'they are today in a temporary folder', () {
      final disk = committed();
      final String good = disk.files['reference/games/b.json']!;
      disk.files['reference/games/b.json'] = good.replaceFirst(
        RegExp('"final":\\["[0-9a-f]'),
        '"final":["x',
      );

      expect(disk.run(['--check']), 1);
      expect(disk.log.first, 'differs: reference/games/b.json');
      expect(disk.log.last, contains('1 of 2 reference games differ'));
      expect(disk.log.last, contains('/tmp/regenerated'));
      expect(disk.files['/tmp/regenerated/b.json'], good);
      expect(disk.files['reference/games/b.json'], isNot(good));
      expect(disk.files.containsKey('/tmp/regenerated/a.json'), isFalse);
    });

    test('--update writes the files that changed back', () {
      final disk = committed();
      final String good = disk.files['reference/games/a.json']!;
      disk.files['reference/games/a.json'] = good.replaceFirst(
        '"turn":7',
        '"turn":8',
      );

      expect(disk.run(['--update']), 0);
      expect(disk.log, ['updated: reference/games/a.json']);
      expect(disk.files['reference/games/a.json'], good);
      expect(disk.run(['--check']), 0);
    });

    test('a dump and a trace left beside a game are not games', () {
      final disk =
          committed()
            ..run([
              '--reference',
              'reference/games/a.json',
              '--dump-turn',
              '2',
              '--trace-turn',
              '2',
            ])
            ..log.clear();

      expect(disk.files, hasLength(5));
      expect(disk.run(['--check']), 0);
      expect(disk.log, ['2 reference games up to date in reference/games']);
    });

    test('another folder can be named', () {
      final disk = MemoryDisk()..run([..._game, '--out', 'other/a.json']);

      expect(disk.run(['--check', 'other']), 0);
      expect(disk.log.last, '1 reference games up to date in other');
    });
  });
}
