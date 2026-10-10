// ignore_for_file: avoid_print
// How a faction plays alone: dart run bin/race.dart [seeds] [turns] [personalityIndex]
import 'dart:math';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';

void main(List<String> args) {

  final int seeds = int.parse(args[0]);
  final int limit = int.parse(args[1]);
  final int index = args.length > 2 ? int.parse(args[2]) : 3;
  final List<int> kernels = [];
  for (int s = (args.length > 4 ? int.parse(args[4]) : 1); s <= seeds; s++) {
    final rnd = Random(s);
    final game = GameFactory.newGame(
        playerName: 'Nemo',
        mapSeed: rnd.nextInt(0x7FFFFFFF),
        personalities: [FactionPersonality.values[index]]);
    final ex = ActionExecutor();
    final p = game.players[game.factions.first.id]!;
    final stage = <String, int>{};
    int level(BuildingType t) => p.buildings[t]!.level;
    while (game.turn < limit) {
      if (game.status == GameStatus.defeat && level(BuildingType.volcanicKernel) < 10) {
        game.status = GameStatus.playing;
      }
      if (game.status != GameStatus.playing) break;
      const BalancedStrategy().playTurn(
          ScriptTurn(game: game, random: SeededRandom(rnd.nextInt(1 << 30)), log: []));
      ex.execute(EndTurnAction(random: SeededRandom(rnd.nextInt(1 << 30))),
          game, game.humanPlayer);
      for (final e in {
        'mod': level(BuildingType.descentModule) > 0,
        'cap': level(BuildingType.pressureCapsule) > 0,
        'ker': level(BuildingType.volcanicKernel) > 0,
        'k5': level(BuildingType.volcanicKernel) >= 5,
        'k10': level(BuildingType.volcanicKernel) >= 10,
        'fall': p.hasFallen,
      }.entries) {
        if (e.value) stage.putIfAbsent(e.key, () => game.turn);
      }
      if (args.length > 3 && game.turn >= int.parse(args[3])) {
        final u = p.unitsPerLevel.map((l, m) => MapEntry(l, m.values.fold(0, (a, b) => a + b.count)));
        print('  T${game.turn} raids ok ${p.raidState.raidsRepelled} lost ${p.raidState.raidsLost}/row ${p.raidState.lostInARow} noise ${p.raidState.totalNoise} units $u kernel ${level(BuildingType.volcanicKernel)} barracks ${level(BuildingType.barracks)} cit ${level(BuildingType.coralCitadel)} incoming ${p.raidState.incoming?.unitCount}');
      }
      if (stage.containsKey('k10')) break;
    }
    print('seed $s: $stage hq ${level(BuildingType.headquarters)} end T${game.turn}');
    if (stage.containsKey('k10')) kernels.add(stage['k10']!);
  }
  print('${personalityName(index)}: ${kernels.length}/$seeds finish the kernel'
      '${kernels.isEmpty ? '' : ', mean turn ${kernels.reduce((a, b) => a + b) / kernels.length}'}');
}

String personalityName(int i) => FactionPersonality.values[i].name;
