import 'dart:convert';

import 'package:abyss/domain/reference/reference_set.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memory_disk.dart';

const _game = ['--strategy', 'economy', '--seed', '2', '--turns', '6'];

void main() {
  test('exports a game to the file asked', () {
    final disk = MemoryDisk();

    expect(disk.run([..._game, '--out', 'games/economy.json']), 0);

    final file = jsonDecode(disk.files['games/economy.json']!) as Map;
    expect(file['result'], {'status': 'playing', 'turn': 7});
    expect(disk.files.keys, ['games/economy.json']);
    expect(disk.log.last, 'playing at turn 7, 7 turns digested');
    expect(disk.log.first, startsWith('wrote games/economy.json ('));
  });

  test('writes the dump and the trace asked beside the game', () {
    final disk = MemoryDisk();

    disk.run([
      ..._game,
      '--out',
      'out/e.json',
      '--dump-turn',
      '3',
      '--trace-turn',
      '2',
    ]);

    expect(disk.files.keys, [
      'out/e.json',
      'out/e.turn-3.dump.json',
      'out/e.turn-2.trace.json',
    ]);
    expect(jsonDecode(disk.files['out/e.turn-3.dump.json']!)['turn'], 3);
    expect(jsonDecode(disk.files['out/e.turn-2.trace.json']!)['turn'], 2);
  });

  test('dumps a turn of an existing reference without writing it again', () {
    final disk = MemoryDisk()..run([..._game, '--out', 'games/e.json']);
    final String committed = disk.files['games/e.json']!;
    disk.files['games/e.json'] = '$committed ';

    disk.run(['--reference', 'games/e.json', '--dump-turn', 'final']);

    expect(disk.files.keys, ['games/e.json', 'games/e.turn-final.dump.json']);
    expect(disk.files['games/e.json'], '$committed ');
    expect(
      jsonDecode(disk.files['games/e.turn-final.dump.json']!)['turn'],
      'final',
    );
  });

  test('a reference file names the source that regenerates it', () {
    final disk = MemoryDisk()..run([..._game, '--out', 'a.json']);

    expect(ReferenceSet.sourceOf(disk.files['a.json']!).toJson(), {
      'strategy': 'economy',
      'seed': 2,
      'difficulty': 'normal',
      'factions': <String>[],
      'turns': 6,
    });
  });
}
