class_name ObjectiveRewards
extends RefCounted
## lib/domain/objective/objective_rewards.dart: resources each objective
## pays, by chapter. Starting values, to retune with the simulator.

const _CORAL := ResourceType.Value.CORAL
const _ORE := ResourceType.Value.ORE
const _ALGAE := ResourceType.Value.ALGAE

const INSTALLATION: Dictionary[ResourceType.Value, int] = {_CORAL: 30, _ORE: 20}
const REEF: Dictionary[ResourceType.Value, int] = {_CORAL: 60, _ORE: 40, _ALGAE: 40}
const RIFT: Dictionary[ResourceType.Value, int] = {_CORAL: 100, _ORE: 70, _ALGAE: 60}
const CHIMNEY: Dictionary[ResourceType.Value, int] = {_CORAL: 150, _ORE: 100, _ALGAE: 90}
const KERNEL: Dictionary[ResourceType.Value, int] = {_CORAL: 200, _ORE: 140, _ALGAE: 120}
const AWAKENING: Dictionary[ResourceType.Value, int] = {_CORAL: 250, _ORE: 170, _ALGAE: 150}
## The last objective wins the game: nothing more to pay.
const VICTORY: Dictionary[ResourceType.Value, int] = {}

const _BY_CHAPTER: Dictionary[ObjectiveChapter.Value, Dictionary] = {
	ObjectiveChapter.Value.INSTALLATION: INSTALLATION,
	ObjectiveChapter.Value.REEF: REEF,
	ObjectiveChapter.Value.RIFT: RIFT,
	ObjectiveChapter.Value.CHIMNEY: CHIMNEY,
	ObjectiveChapter.Value.KERNEL: KERNEL,
	ObjectiveChapter.Value.AWAKENING: AWAKENING,
}


## What each objective of `chapter` pays, the victory aside.
static func of_chapter(chapter: ObjectiveChapter.Value) -> Dictionary[ResourceType.Value, int]:
	var reward: Dictionary[ResourceType.Value, int] = _BY_CHAPTER[chapter]
	return reward
