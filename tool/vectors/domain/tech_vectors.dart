import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_cost_calculator.dart';
import 'package:abyss/domain/tech/tech_effects.dart';
import 'package:abyss/domain/tech/tech_tree.dart';

import '../vector_file.dart';
import 'tech_cases.dart';
import 'vector_inputs.dart';

/// Costs of every research and what each state of the research changes.
abstract final class TechVectors {
  static final VectorFile file = VectorFile('tech', {
    'unlockCost': VectorSection(
      'TechCostCalculator.unlockCost(branch, opened: opened); percent is '
          'TechCostCalculator.costPercent(opened)',
      () => [
        for (final TechBranch branch in TechBranch.values)
          for (var opened = 0; opened <= 3; opened++)
            {
              'branch': branch,
              'opened': opened,
              'percent': TechCostCalculator.costPercent(opened),
              'out': TechCostCalculator.unlockCost(branch, opened: opened),
            },
      ],
    ),
    'researchCost': VectorSection(
      'TechCostCalculator.researchCost(branch, level, opened: opened); '
          'nothing outside levels 1 to 5',
      () => [
        for (final TechBranch branch in TechBranch.values)
          for (var level = 0; level <= TechTree.maxLevel + 1; level++)
            for (var opened = 0; opened <= 3; opened++)
              {
                'branch': branch,
                'level': level,
                'opened': opened,
                'out': TechCostCalculator.researchCost(
                  branch,
                  level,
                  opened: opened,
                ),
              },
      ],
    ),
    'branchState': VectorSection(
      'TechBranchState(branch: branch, unlocked: unlocked, researchLevel: '
          'level, choices: choices): tiers, perks in order, and '
          'optionAt(l) for l = 1 to 5',
      () => [
        for (final TechBranch branch in TechBranch.values)
          for (final bool unlocked in const [true, false])
            for (final (int level, List<int> choices) in TechCases.states)
              {
                'branch': branch,
                'unlocked': unlocked,
                'level': level,
                'choices': choices,
                'out': _state(
                  TechBranchState(
                    branch: branch,
                    unlocked: unlocked,
                    researchLevel: level,
                    choices: choices,
                  ),
                ),
              },
      ],
    ),
    'effects': VectorSection(
      'TechEffects(tech, halved: halved) with tech = {branch: [level, '
          'choices]} for the unlocked branches, the others locked: see '
          'the README for the getter behind each key of out',
      () => [
        for (final research in TechCases.researches)
          for (final bool halved in const [false, true])
            {
              'tech': VectorInputs.techJson(research),
              'halved': halved,
              'out': effects(
                TechEffects(VectorInputs.tech(research), halved: halved),
              ),
            },
      ],
    ),
  });

  static Map<String, Object?> _state(TechBranchState s) => {
    'tiers': s.tiers,
    'perks': s.perks.toList(),
    'options': [
      for (var l = 1; l <= TechTree.maxLevel; l++) s.optionAt(l),
    ],
  };

  /// Every number [e] changes in the rules.
  static Map<String, Object?> effects(TechEffects e) => {
    'atk': e.atkPercent(),
    'atkAttacking': e.atkPercent(attacking: true),
    'def': e.defPercent(),
    'defBase': e.defPercent(defendingBase: true),
    'hp': e.hpPercent,
    'production': {
      for (final ResourceType type in ResourceType.values)
        type: e.productionPercent(type),
    },
    'pillageRate': e.pillageRate,
    'upgradeDiscount': e.upgradeDiscountPercent,
    'revealSide': e.revealSide,
    'muffle': [for (final int noise in const [0, 1, 3, 7]) e.muffle(noise)],
    'lootPercent': e.lootPercent,
    'raidWarningTurns': e.raidWarningTurns,
    'boostLoot': e.boostLoot(const {
      ResourceType.algae: 333,
      ResourceType.coral: 1,
      ResourceType.pearl: 3,
    }),
  };
}
