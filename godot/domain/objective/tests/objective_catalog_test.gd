extends TestCase
## test/domain/objective/objective_catalog_test.dart: the chapters, the
## catalog of the objectives and what they pay. Left out: "ObjectiveId is
## saved by a Hive adapter of type 53", which never comes.

const Id := ObjectiveId.Value
const Chapter := ObjectiveChapter.Value
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ALGAE := ResourceType.Value.ALGAE


func test_objective_chapter_six_chapters_in_order_the_tutorial_first() -> void:
	assert_eq(
		DartEnum.names(Chapter),
		PackedStringArray(["installation", "reef", "rift", "chimney", "kernel", "awakening"]),
	)


func test_objective_catalog_holds_every_objective_id_exactly_once_in_enum_order() -> void:
	var ids: Array = []
	for objective: Objective in ObjectiveCatalog.all():
		ids.append(objective.id)
	assert_eq(ids, Id.values())


func test_objective_catalog_chapters_follow_each_other_in_order() -> void:
	var chapters: Array[int] = []
	var seen: Dictionary[int, bool] = {}
	for objective: Objective in ObjectiveCatalog.all():
		chapters.append(objective.chapter)
		seen[objective.chapter] = true
	var sorted := chapters.duplicate()
	sorted.sort()
	assert_eq(chapters, sorted)
	assert_eq(seen.keys(), Chapter.values())


func test_objective_catalog_objectives_per_chapter() -> void:
	var counts: Array[int] = []
	for chapter: Chapter in Chapter.values():
		counts.append(ObjectiveCatalog.of_chapter(chapter).size())
	assert_eq(counts, [10, 3, 3, 4, 3, 2] as Array[int])
	var rift: Array = []
	for objective: Objective in ObjectiveCatalog.of_chapter(Chapter.RIFT):
		rift.append(objective.id)
	assert_eq(rift, [Id.TAKE_FAILLE, Id.DESCENT_MODULE, Id.DESCEND_LEVEL_2])


func test_objective_catalog_by_id_finds_the_objective_with_its_chapter_and_goal() -> void:
	var objective := ObjectiveCatalog.by_id(Id.MINES)
	assert_eq(objective.id, Id.MINES)
	assert_eq(objective.chapter, Chapter.INSTALLATION)
	assert_true(objective.goal is AllOfGoal)
	var kernel := ObjectiveCatalog.by_id(Id.KERNEL_LEVEL_10).goal as BuildingLevelGoal
	assert_eq(kernel.type, BuildingType.Value.VOLCANIC_KERNEL)
	assert_eq(kernel.level, 10)


func test_objective_catalog_first_not_done_skips_the_completed_ids_in_catalog_order() -> void:
	assert_eq(ObjectiveCatalog.first_not_done({}).id, Id.HQ_LEVEL_1)
	assert_eq(ObjectiveCatalog.first_not_done({Id.HQ_LEVEL_1: true, Id.MINES: true}).id, Id.ALGAE_FARM)
	var every: Dictionary[Id, bool] = {}
	for id: Id in Id.values():
		every[id] = true
	assert_null(ObjectiveCatalog.first_not_done(every))


func test_objective_rewards_each_chapter_pays_its_reward_the_victory_nothing() -> void:
	assert_eq(_reward_of(Id.HQ_LEVEL_1), {CORAL: 30, ORE: 20})
	assert_eq(_reward_of(Id.CORAL_CITADEL), ObjectiveRewards.REEF)
	assert_eq(_reward_of(Id.TAKE_FAILLE), ObjectiveRewards.RIFT)
	assert_eq(_reward_of(Id.HQ_LEVEL_8), ObjectiveRewards.CHIMNEY)
	assert_eq(_reward_of(Id.TAKE_KERNEL), ObjectiveRewards.KERNEL)
	assert_eq(_reward_of(Id.KERNEL_LEVEL_5), {CORAL: 250, ORE: 170, ALGAE: 150})
	assert_true(_reward_of(Id.KERNEL_LEVEL_10).is_empty())
	assert_eq(ObjectiveRewards.of_chapter(Chapter.INSTALLATION), ObjectiveRewards.INSTALLATION)


func test_objective_rewards_every_objective_of_a_chapter_but_the_victory_pays_something() -> void:
	for objective: Objective in ObjectiveCatalog.all():
		if objective.id == Id.KERNEL_LEVEL_10:
			continue
		assert_false(objective.reward.is_empty(), DartEnum.name_of(Id, objective.id))


## Not in the Dart file: the reward of each chapter in the order of its
## resources, which is the order they are credited in.
func test_each_chapter_pays_in_the_dart_order_of_its_resources() -> void:
	var expected: Array = [[30, 20], [60, 40, 40], [100, 70, 60], [150, 100, 90], [200, 140, 120], [250, 170, 150]]
	for chapter: Chapter in Chapter.values():
		var reward := ObjectiveRewards.of_chapter(chapter)
		assert_eq(reward.keys(), [CORAL, ORE, ALGAE].slice(0, reward.size()))
		assert_eq(reward.values(), expected[chapter])
	assert_true(ObjectiveRewards.VICTORY.is_empty())


func _reward_of(id: Id) -> Dictionary[ResourceType.Value, int]:
	return ObjectiveCatalog.by_id(id).reward
