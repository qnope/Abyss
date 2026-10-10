import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/screens/menu/load_game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';

import 'fake_game_repository.dart';

/// The time the load screen tells the save dates against.
final loadScreenNow = DateTime(2026, 10, 10, 12);

/// The load screen over [repository], with motion reduced so the backdrop
/// stands still and `pumpAndSettle` returns.
Widget loadGameApp(FakeGameRepository repository) => MaterialApp(
  theme: AbyssTheme.create(),
  builder:
      (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
  home: LoadGameScreen(repository: repository, now: () => loadScreenNow),
);

/// A save of [name], last played [hoursAgo] before [loadScreenNow].
Game savedGame(
  String name, {
  GameStatus status = GameStatus.playing,
  int hoursAgo = 1,
  int turn = 5,
}) {
  final player = Player(name: name);
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    turn: turn,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    lastPlayedAt: loadScreenNow.subtract(Duration(hours: hoursAgo)),
  );
}
