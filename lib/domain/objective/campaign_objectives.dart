import '../building/building_type.dart';
import '../map/transition_base_type.dart';
import '../resource/resource_type.dart';
import 'goals/building_level_goal.dart';
import 'goals/kernel_captured_goal.dart';
import 'goals/lair_taken_goal.dart';
import 'goals/level_reached_goal.dart';
import 'goals/transition_base_captured_goal.dart';
import 'objective.dart';
import 'objective_chapter.dart';
import 'objective_goal.dart';
import 'objective_id.dart';
import 'objective_rewards.dart';

/// An objective of [chapter] paying the [ObjectiveRewards] of its chapter.
Objective _step(
  ObjectiveId id,
  ObjectiveChapter chapter,
  String title,
  ObjectiveGoal goal, {
  Map<ResourceType, int>? reward,
}) => Objective(
  id: id,
  chapter: chapter,
  title: title,
  reward: reward ?? ObjectiveRewards.ofChapter(chapter),
  goal: goal,
);

const _hq = BuildingType.headquarters;
const _kernel = BuildingType.volcanicKernel;

/// The chapters after the tutorial, up to the victory.
final List<Objective> campaignObjectives = [
  _step(
    ObjectiveId.takeLair,
    ObjectiveChapter.reef,
    'Prends un repaire',
    const LairTakenGoal(),
  ),
  _step(
    ObjectiveId.hqLevel5,
    ObjectiveChapter.reef,
    'Monte le QG au niveau 5',
    const BuildingLevelGoal(_hq, 5),
  ),
  _step(
    ObjectiveId.coralCitadel,
    ObjectiveChapter.reef,
    'Construis la Citadelle corallienne',
    const BuildingLevelGoal(BuildingType.coralCitadel, 1),
  ),
  _step(
    ObjectiveId.takeFaille,
    ObjectiveChapter.rift,
    'Prends la Faille',
    const TransitionBaseCapturedGoal(TransitionBaseType.faille),
  ),
  _step(
    ObjectiveId.descentModule,
    ObjectiveChapter.rift,
    'Construis le Module de Descente',
    const BuildingLevelGoal(BuildingType.descentModule, 1),
  ),
  _step(
    ObjectiveId.descendLevel2,
    ObjectiveChapter.rift,
    'Descends au niveau 2',
    const LevelReachedGoal(2),
  ),
  _step(
    ObjectiveId.hqLevel8,
    ObjectiveChapter.chimney,
    'Monte le QG au niveau 8',
    const BuildingLevelGoal(_hq, 8),
  ),
  _step(
    ObjectiveId.takeCheminee,
    ObjectiveChapter.chimney,
    'Prends la Cheminée',
    const TransitionBaseCapturedGoal(TransitionBaseType.cheminee),
  ),
  _step(
    ObjectiveId.pressureCapsule,
    ObjectiveChapter.chimney,
    'Construis la Capsule Pressurisée',
    const BuildingLevelGoal(BuildingType.pressureCapsule, 1),
  ),
  _step(
    ObjectiveId.descendLevel3,
    ObjectiveChapter.chimney,
    'Descends au niveau 3',
    const LevelReachedGoal(3),
  ),
  _step(
    ObjectiveId.hqLevel10,
    ObjectiveChapter.kernel,
    'Monte le QG au niveau 10',
    const BuildingLevelGoal(_hq, 10),
  ),
  _step(
    ObjectiveId.takeKernel,
    ObjectiveChapter.kernel,
    'Prends le Noyau Volcanique',
    const KernelCapturedGoal(),
  ),
  _step(
    ObjectiveId.kernelLevel1,
    ObjectiveChapter.kernel,
    'Monte le Noyau au niveau 1',
    const BuildingLevelGoal(_kernel, 1),
  ),
  _step(
    ObjectiveId.kernelLevel5,
    ObjectiveChapter.awakening,
    'Monte le Noyau au niveau 5',
    const BuildingLevelGoal(_kernel, 5),
  ),
  _step(
    ObjectiveId.kernelLevel10,
    ObjectiveChapter.awakening,
    'Monte le Noyau au niveau 10',
    const BuildingLevelGoal(_kernel, 10),
    reward: ObjectiveRewards.victory,
  ),
];
