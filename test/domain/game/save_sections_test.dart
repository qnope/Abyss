import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/save_sections.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game(String name, GameStatus status, DateTime lastPlayedAt) {
  final Player player = Player(name: name);
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    status: status,
    createdAt: DateTime(2026),
    lastPlayedAt: lastPlayedAt,
  );
}

void main() {
  final Game oldRun = _game('A', GameStatus.playing, DateTime(2026, 1, 3));
  final Game recentRun = _game('B', GameStatus.playing, DateTime(2026, 2, 1));
  final Game won = _game('C', GameStatus.victory, DateTime(2026, 1, 1));
  final Game free = _game('D', GameStatus.freePlay, DateTime(2026, 3, 1));
  final Game lost = _game('E', GameStatus.defeat, DateTime(2026, 2, 5));

  test('no save gives two empty sections and nothing to continue', () {
    final SaveSections sections = SaveSections.of(const []);
    expect(sections.inProgress, isEmpty);
    expect(sections.finished, isEmpty);
    expect(sections.isEmpty, isTrue);
    expect(sections.mostRecentInProgress, isNull);
  });

  test('games still played are in progress, latest played first', () {
    final SaveSections sections = SaveSections.of([
      oldRun,
      won,
      recentRun,
      lost,
    ]);
    expect(sections.inProgress, [recentRun, oldRun]);
  });

  test('a game won then played on is still in progress', () {
    final SaveSections sections = SaveSections.of([
      won,
      oldRun,
      lost,
      free,
      recentRun,
    ]);
    expect(sections.inProgress, [free, recentRun, oldRun]);
  });

  test('won and lost games are finished, latest played first', () {
    final SaveSections sections = SaveSections.of([
      won,
      oldRun,
      lost,
      free,
      recentRun,
    ]);
    expect(sections.finished, [lost, won]);
    expect(sections.isEmpty, isFalse);
  });

  test('the game to continue is the latest played in progress', () {
    final SaveSections sections = SaveSections.of([oldRun, recentRun]);
    expect(sections.mostRecentInProgress, same(recentRun));
  });

  test('a game in free play can be continued', () {
    final SaveSections sections = SaveSections.of([oldRun, free, recentRun]);
    expect(sections.mostRecentInProgress, same(free));
  });

  test('only finished games leave nothing to continue', () {
    final SaveSections sections = SaveSections.of([won, lost]);
    expect(sections.mostRecentInProgress, isNull);
  });

  test('an old save without stamp is ordered by its creation', () {
    final Player player = Player(name: 'Old');
    final Game legacy = Game(
      humanPlayerId: player.id,
      players: {player.id: player},
      createdAt: DateTime(2026, 1, 10),
    );
    final SaveSections sections = SaveSections.of([oldRun, legacy]);
    expect(sections.inProgress, [legacy, oldRun]);
  });

  test('the sections cannot be changed from outside', () {
    final SaveSections sections = SaveSections.of([oldRun, won]);
    expect(() => sections.inProgress.add(won), throwsUnsupportedError);
    expect(() => sections.finished.clear(), throwsUnsupportedError);
  });

  test('counts every save, in progress or finished', () {
    expect(SaveSections.of([oldRun, won, lost]).count, 3);
    expect(SaveSections.of(const []).count, 0);
  });
}
