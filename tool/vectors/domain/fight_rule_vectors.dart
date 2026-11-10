import 'package:abyss/domain/fight/attack_damage.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/damage_calculator.dart';
import 'package:abyss/domain/fight/monster_rules.dart';

import '../vector_file.dart';
import 'fight_force_vectors.dart';
import 'fight_scenarios.dart';
import 'vector_inputs.dart';

/// The rules of one blow and the stats of everything that fights.
abstract final class FightRuleVectors {
  static const List<int> _atks = <int>[
    0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 16, 17, 18, 20, 25, 27, 35,
  ];

  static const List<int> _defs = <int>[
    -1, 0, 1, 2, 3, 4, 5, 6, 7, 10, 12, 15, 20, 25, 30,
  ];

  static final VectorFile file = VectorFile('fight_rules', {
    'damage': VectorSection(
      'For each def of defs, [DamageCalculator.compute(atk: atk, def: '
          'def), the same with crit: true, with ignoreDef: true, with '
          'multiplier: 2, and with crit: true, multiplier: 4]',
      () => [
        for (final int atk in _atks)
          {
            'atk': atk,
            'defs': _defs,
            'out': [
              for (final int def in _defs) _damages(atk, def),
            ],
          },
      ],
    ),
    'attackDamage': VectorSection(
      'attacker and target are Combatant(...) written [typeKey, side, '
          'maxHp, atk, def, currentHp, isBoss], one of each kind of the '
          'fights: attacker.role, MonsterRules.hunts(attacker), '
          'MonsterRules.multiplier(attacker, target), then '
          'AttackDamage.compute(attacker: attacker, target: target) and '
          'with crit: true',
      () => [
        for (final Combatant attacker in samples())
          for (final Combatant target in samples())
            if (attacker.side != target.side)
              {
                'attacker': VectorInputs.combatant(attacker),
                'target': VectorInputs.combatant(target),
                'out': {
                  'role': attacker.role,
                  'hunts': MonsterRules.hunts(attacker),
                  'multiplier': MonsterRules.multiplier(attacker, target),
                  'damage': AttackDamage.compute(
                    attacker: attacker,
                    target: target,
                  ),
                  'crit': AttackDamage.compute(
                    attacker: attacker,
                    target: target,
                    crit: true,
                  ),
                },
              },
      ],
    ),
    ...FightForceSections.sections,
  });

  static List<int> _damages(int atk, int def) => [
    DamageCalculator.compute(atk: atk, def: def),
    DamageCalculator.compute(atk: atk, def: def, crit: true),
    DamageCalculator.compute(atk: atk, def: def, ignoreDef: true),
    DamageCalculator.compute(atk: atk, def: def, multiplier: 2),
    DamageCalculator.compute(atk: atk, def: def, crit: true, multiplier: 4),
  ];

  /// One combatant of each kind and side: every unit, both ramparts, a
  /// monster of each family, the guardians.
  static List<Combatant> samples() {
    final Map<String, Combatant> kinds = <String, Combatant>{};
    for (final String fight in const [
      'every unit, boosted', 'raid on a rampart', 'krakens on a kernel',
      'faille', 'generic hard', 'harpoons sweep a swarm',
      'saboteurs pierce armour', 'guardians draw hunters',
      'base against base',
    ]) {
      final (players, monsters) = FightScenarios.all[fight]!;
      for (final Combatant c in [...players(), ...monsters()]) {
        kinds.putIfAbsent('${c.typeKey} ${c.side.name}', () => c);
      }
    }
    return kinds.values.toList();
  }
}
