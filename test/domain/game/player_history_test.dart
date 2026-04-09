import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_constants.dart';
import 'package:abyss/domain/history/history_entry.dart';

HistoryEntry _entry(int turn) => BuildingEntry(
      turn: turn,
      buildingType: BuildingType.algaeFarm,
      newLevel: turn,
    );

void main() {
  group('Player.historyEntries', () {
    test('new player has empty history', () {
      final player = Player(name: 'p');
      expect(player.historyEntries, isEmpty);
    });

    test('addHistoryEntry appends a single entry', () {
      final player = Player(name: 'p');
      final entry = _entry(1);
      player.addHistoryEntry(entry);
      expect(player.historyEntries, hasLength(1));
      expect(player.historyEntries.first, same(entry));
    });

    test('FIFO cap drops oldest entries when exceeding kHistoryMaxEntries', () {
      final player = Player(name: 'p');
      for (var i = 1; i <= 150; i++) {
        player.addHistoryEntry(_entry(i));
      }

      expect(player.historyEntries.length, kHistoryMaxEntries);
      // Oldest kept entry is turn 51 (entries 1..50 dropped).
      final first = player.historyEntries.first as BuildingEntry;
      expect(first.turn, 51);
      // Newest entry is the last one added (turn 150).
      final last = player.historyEntries.last as BuildingEntry;
      expect(last.turn, 150);
    });

    test('order is oldest-first, newest-last', () {
      final player = Player(name: 'p');
      player.addHistoryEntry(_entry(1));
      player.addHistoryEntry(_entry(2));
      player.addHistoryEntry(_entry(3));

      expect((player.historyEntries[0] as BuildingEntry).turn, 1);
      expect((player.historyEntries[1] as BuildingEntry).turn, 2);
      expect((player.historyEntries.last as BuildingEntry).turn, 3);
    });

    test('two players have independent history lists', () {
      final a = Player(name: 'a');
      final b = Player(name: 'b');
      a.addHistoryEntry(_entry(1));
      expect(a.historyEntries, hasLength(1));
      expect(b.historyEntries, isEmpty);
    });
  });
}
