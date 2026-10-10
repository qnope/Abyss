import 'package:abyss/domain/action/action.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/garrison_kernel_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/action/research_tech_action.dart';
import 'package:abyss/domain/action/send_reinforcements_action.dart';
import 'package:abyss/domain/action/unlock_branch_action.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<UnitType, int> _units = {UnitType.harpoonist: 3};

/// Each player action with the kind it reports and the line a script log
/// writes for it.
final List<(Action, ActionType, String)> _actions = [
  (
    ResearchTechAction(branch: TechBranch.military),
    ActionType.researchTech,
    'Rechercher tech TechBranch.military',
  ),
  (
    UnlockBranchAction(branch: TechBranch.explorer),
    ActionType.unlockBranch,
    'Debloquer branche TechBranch.explorer',
  ),
  (
    RecruitUnitAction(unitType: UnitType.scout, quantity: 2),
    ActionType.recruitUnit,
    'Recruter 2 UnitType.scout',
  ),
  (
    ExploreAction(targetX: 4, targetY: 5),
    ActionType.explore,
    'Explorer (4, 5)',
  ),
  (
    CollectTreasureAction(targetX: 1, targetY: 2),
    ActionType.collectTreasure,
    'Collecter (1, 2)',
  ),
  (
    FightMonsterAction(targetX: 3, targetY: 6, level: 1, selectedUnits: _units),
    ActionType.fightMonster,
    'Combat (3, 6)',
  ),
  (
    AttackTransitionBaseAction(
        targetX: 7, targetY: 8, level: 1, selectedUnits: _units),
    ActionType.attackTransitionBase,
    'Assaut base (7, 8)',
  ),
  (
    AttackVolcanicKernelAction(
        targetX: 0, targetY: 0, level: 3, selectedUnits: _units),
    ActionType.attackVolcanicKernel,
    'Assaut Noyau Volcanique',
  ),
  (
    DescendAction(
        transitionX: 2, transitionY: 2, fromLevel: 1, selectedUnits: _units),
    ActionType.descend,
    'Descente niveau 1',
  ),
  (
    SendReinforcementsAction(
        transitionX: 2, transitionY: 2, fromLevel: 1, selectedUnits: _units),
    ActionType.sendReinforcements,
    'Envoyer des renforts',
  ),
  (
    GarrisonKernelAction(selectedUnits: _units),
    ActionType.garrisonKernel,
    'Mettre en garnison',
  ),
  (
    GarrisonKernelAction(selectedUnits: _units, withdraw: true),
    ActionType.garrisonKernel,
    'Retirer de la garnison',
  ),
];

void main() {
  for (final (Action action, ActionType type, String line) in _actions) {
    test('${type.name} is logged as "$line"', () {
      expect(action.type, type);
      expect(action.description, line);
    });
  }
}
