import '../building/building_type.dart';
import '../unit/unit_type.dart';
import 'goals/all_of_goal.dart';
import 'goals/building_level_goal.dart';
import 'goals/explored_around_base_goal.dart';
import 'goals/raids_repelled_goal.dart';
import 'goals/research_started_goal.dart';
import 'goals/unit_count_goal.dart';
import 'objective.dart';
import 'objective_chapter.dart';
import 'objective_id.dart';
import 'objective_rewards.dart';

const _chapter = ObjectiveChapter.installation;
const _reward = ObjectiveRewards.installation;

/// The tutorial: the first chapter, given one objective at a time.
const List<Objective> installationObjectives = [
  Objective(
    id: ObjectiveId.hqLevel1,
    chapter: _chapter,
    reward: _reward,
    goal: BuildingLevelGoal(BuildingType.headquarters, 1),
  ),
  Objective(
    id: ObjectiveId.algaeFarm,
    chapter: _chapter,
    reward: _reward,
    goal: BuildingLevelGoal(BuildingType.algaeFarm, 1),
  ),
  Objective(
    id: ObjectiveId.mines,
    chapter: _chapter,
    reward: _reward,
    goal: AllOfGoal([
      BuildingLevelGoal(BuildingType.coralMine, 1),
      BuildingLevelGoal(BuildingType.oreExtractor, 1),
    ]),
  ),
  Objective(
    id: ObjectiveId.solarPanel,
    chapter: _chapter,
    reward: _reward,
    goal: BuildingLevelGoal(BuildingType.solarPanel, 1),
  ),
  Objective(
    id: ObjectiveId.hqLevel2,
    chapter: _chapter,
    reward: _reward,
    goal: BuildingLevelGoal(BuildingType.headquarters, 2),
  ),
  Objective(
    id: ObjectiveId.barracksAndScouts,
    chapter: _chapter,
    reward: _reward,
    goal: AllOfGoal([
      BuildingLevelGoal(BuildingType.barracks, 1),
      UnitCountGoal(UnitType.scout, 2),
    ]),
  ),
  Objective(
    id: ObjectiveId.explore,
    chapter: _chapter,
    reward: _reward,
    goal: ExploredAroundBaseGoal(),
  ),
  Objective(
    id: ObjectiveId.laboratoryAndResearch,
    chapter: _chapter,
    reward: _reward,
    goal: AllOfGoal([
      BuildingLevelGoal(BuildingType.laboratory, 1),
      ResearchStartedGoal(),
    ]),
  ),
  Objective(
    id: ObjectiveId.firstRaid,
    chapter: _chapter,
    reward: _reward,
    goal: RaidsRepelledGoal(1),
  ),
];
