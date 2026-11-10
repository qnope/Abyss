import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/fight/army_rehearsal.dart';

import '../vector_file.dart';
import 'assault_vectors.dart';
import 'fight_planning_cases.dart';
import 'fight_scenarios.dart';
import 'vector_inputs.dart';

/// Fights rehearsed before they are fought: the strength of a side, the
/// share of rehearsals won, the chances of an assault.
abstract final class FightPlanningVectors {
  static const String _plan =
      'army lists [type, count] in order, boost is UnitBoost(atkPercent, '
      'defPercent, hpPercent), enemy() gives fresh Combatant(...) from the '
      'runs [typeKey, side, maxHp, atk, def, isBoss, count]';

  static final VectorFile file = VectorFile('fight_planning', {
    'strength': VectorSection(
      '[ArmyRehearsal.strength(players, monsters), ArmyRehearsal'
          '.strength(monsters, players)], the sides of fight_engine.json',
      () => [
        for (final e in FightScenarios.all.entries)
          {
            'fight': e.key,
            'players': VectorInputs.runs(e.value.$1()),
            'monsters': VectorInputs.runs(e.value.$2()),
            'out': [
              ArmyRehearsal.strength(e.value.$1(), e.value.$2()),
              ArmyRehearsal.strength(e.value.$2(), e.value.$1()),
            ],
          },
      ],
    ),
    'rehearsal': VectorSection(
      'r = ArmyRehearsal(army, enemy, boost: boost, needsAdmiral: '
          'needsAdmiral): r.hopeless, r.wins(rehearsals), and '
          'r.wins(rehearsals, needed: n) for n = 0 to rehearsals; $_plan',
      () => [
        for (final PlannedFight f in FightPlanningCases.fights)
          for (final int rehearsals in const [1, 8, 20])
            {...f.toJson(), 'rehearsals': rehearsals, 'out': _wins(f, rehearsals)},
      ],
    ),
    'planner': VectorSection(
      'p = ArmyPlanner(rehearsals: rehearsals, confidence: confidence): '
          'p.winRate(army, enemy, boost: boost, needsAdmiral: '
          'needsAdmiral), p.wins(...) with the same arguments, and '
          'p.smallestWinning(maxK, (k) => army plus k harpoonists, enemy, '
          '...) for each maxK of maxKs; $_plan',
      () => [
        for (final PlannedFight f in FightPlanningCases.fights)
          for (final (int rehearsals, double confidence) in const [
            (8, 0.85), (8, 0.625), (20, 0.95), (50, 0.95), (8, 1.1),
          ])
            {
              ...f.toJson(),
              'rehearsals': rehearsals,
              'confidence': confidence,
              'maxKs': FightPlanningCases.maxKs,
              'out': _planner(
                f,
                ArmyPlanner(rehearsals: rehearsals, confidence: confidence),
              ),
            },
      ],
    ),
    ...AssaultSections.sections,
  });

  static Map<String, Object?> _wins(PlannedFight f, int rehearsals) {
    final ArmyRehearsal r = f.rehearsal;
    return {
      'hopeless': r.hopeless,
      'wins': r.wins(rehearsals),
      'winsNeeding': [
        for (var n = 0; n <= rehearsals; n++) r.wins(rehearsals, needed: n),
      ],
    };
  }

  static Map<String, Object?> _planner(PlannedFight f, ArmyPlanner p) => {
    'winRate': p.winRate(
      f.army,
      f.enemy,
      boost: f.boost,
      needsAdmiral: f.needsAdmiral,
    ),
    'wins': p.wins(
      f.army,
      f.enemy,
      boost: f.boost,
      needsAdmiral: f.needsAdmiral,
    ),
    'smallestWinning': [
      for (final int maxK in FightPlanningCases.maxKs)
        p.smallestWinning(
          maxK,
          f.withHarpoonists,
          f.enemy,
          boost: f.boost,
          needsAdmiral: f.needsAdmiral,
        ),
    ],
  };
}
