import '../fight/combat_side.dart';
import '../fight/combatant.dart';
import '../fight/guardian_factory.dart';
import '../game/game.dart';

/// The guardians that come back to the human's first Faille: a Léviathan
/// and [sentinels] Sentinelles, those of a Faille ([GuardianFactory]),
/// scaled like the other monsters of the game. They attack, so they fight
/// on the player's side of the engine, the defenders on the other.
abstract final class LeviathanForce {
  /// Sentinelles at the Léviathan's side, one less than on a Faille.
  static const int sentinels = 4;

  /// Type keys of the force, as the fight and the reports name them.
  static const String leviathanKey = 'leviathan';
  static const String sentinelKey = 'sentinelle';

  /// Name of the attacker in the history and the end-of-turn reports.
  static const String attackerName = leviathanKey;

  /// How many of each kind come.
  static const Map<String, int> counts = <String, int>{
    leviathanKey: 1,
    sentinelKey: sentinels,
  };

  /// The share of their strength the monsters keep against the human in
  /// [game], in percent (see `Difficulty.monsterPercentFor`).
  static int percentOf(Game game) => game.difficulty.monsterPercentFor(
    faction: false,
    factions: game.factions.length,
  );

  /// The force that strikes in [game].
  static List<Combatant> of(Game game) =>
      combatants(monsterPercent: percentOf(game));

  /// The force, its health and attack scaled by [monsterPercent].
  static List<Combatant> combatants({int monsterPercent = 100}) {
    final List<Combatant> faille = GuardianFactory.forFaille();
    final Combatant leviathan = faille.firstWhere((Combatant c) => c.isBoss);
    final Combatant sentinel = faille.firstWhere((Combatant c) => !c.isBoss);
    return <Combatant>[
      _scaled(leviathan, monsterPercent),
      for (int i = 0; i < sentinels; i++) _scaled(sentinel, monsterPercent),
    ];
  }

  static Combatant _scaled(Combatant c, int percent) => Combatant(
    side: CombatSide.player,
    typeKey: c.typeKey,
    maxHp: c.maxHp * percent ~/ 100,
    atk: c.atk * percent ~/ 100,
    def: c.def,
    isBoss: c.isBoss,
  );
}
