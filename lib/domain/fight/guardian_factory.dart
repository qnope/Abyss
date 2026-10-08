import 'combat_side.dart';
import 'combatant.dart';
import '../map/transition_base_type.dart';

class GuardianFactory {
  static List<Combatant> forFaille() => [
        Combatant(
          side: CombatSide.monster,
          typeKey: 'leviathan',
          maxHp: 100,
          atk: 15,
          def: 10,
          isBoss: true,
        ),
        ...List.generate(
          5,
          (_) => Combatant(
            side: CombatSide.monster,
            typeKey: 'sentinelle',
            maxHp: 30,
            atk: 8,
            def: 4,
          ),
        ),
      ];

  static List<Combatant> forCheminee() => [
        Combatant(
          side: CombatSide.monster,
          typeKey: 'titanVolcanique',
          maxHp: 200,
          atk: 25,
          def: 15,
          isBoss: true,
        ),
        ...List.generate(
          8,
          (_) => Combatant(
            side: CombatSide.monster,
            typeKey: 'golemMagma',
            maxHp: 50,
            atk: 12,
            def: 7,
          ),
        ),
      ];

  /// The final fight: about 130 units without Military research, 80 with
  /// all of it (see the conquest simulation).
  static List<Combatant> forVolcanicKernel() => [
        Combatant(
          side: CombatSide.monster,
          typeKey: 'seigneurNoyau',
          maxHp: 1050,
          atk: 35,
          def: 20,
          isBoss: true,
        ),
        ...List.generate(
          30,
          (_) => Combatant(
            side: CombatSide.monster,
            typeKey: 'sentinelleNoyau',
            maxHp: 80,
            atk: 18,
            def: 10,
          ),
        ),
      ];

  static List<Combatant> forType(TransitionBaseType type) => switch (type) {
        TransitionBaseType.faille => forFaille(),
        TransitionBaseType.cheminee => forCheminee(),
      };
}
