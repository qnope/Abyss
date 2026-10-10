import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plays [inner] and checks, after each of its turns, that no building of
/// any player is degraded: nothing lowers the headquarters yet.
class _Watching extends GameScript {
  final GameScript inner;
  final List<String> degraded = <String>[];

  _Watching(this.inner);

  @override
  String get name => inner.name;

  @override
  List<FactionPersonality> get factions => inner.factions;

  @override
  void playTurn(ScriptTurn turn) {
    inner.playTurn(turn);
    final Game game = turn.game;
    for (final player in game.players.values) {
      for (final BuildingType type in BuildingType.values) {
        if (player.isDegraded(type)) {
          degraded.add('${player.name} $type turn ${game.turn}');
        }
      }
    }
  }
}

void main() {
  for (final entry
      in <String, GameScript>{
        'balanced': const BalancedStrategy(),
        'conquest': const ConquestStrategy(),
      }.entries) {
    test('no building is ever degraded in a ${entry.key} game', () {
      final watching = _Watching(entry.value);
      ScriptRunner(maxTurns: 60).run(watching, seed: 3);
      expect(watching.degraded, isEmpty);
    });
  }
}
