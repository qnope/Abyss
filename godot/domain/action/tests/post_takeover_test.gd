extends TestCase
## Not in the Dart files: lib/domain/action/post_takeover.dart and
## post_loss.dart, which the tests of the attacks on a post read through
## the actions: the passage of each post, built, working or degraded, and
## what a takeover leaves.

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE
const MODULE := BuildingType.Value.DESCENT_MODULE
const CAPSULE := BuildingType.Value.PRESSURE_CAPSULE
const HQ := BuildingType.Value.HEADQUARTERS


func test_each_post_has_its_passage_which_works_once_built_and_not_degraded() -> void:
	assert_eq([PostTakeover.passage_of(FAILLE), PostTakeover.passage_of(CHEMINEE)], [MODULE, CAPSULE])
	var player := ActionSamples.stocked({}, {HQ: 10, MODULE: 1})
	assert_true(PostTakeover.passage_built(player, FAILLE))
	assert_true(PostTakeover.passage_works(player, FAILLE))
	assert_false(PostTakeover.passage_built(player, CHEMINEE))
	assert_false(PostTakeover.passage_works(player, CHEMINEE))
	player.buildings[MODULE].level = 5
	player.buildings[HQ].level = 1
	assert_true(PostTakeover.passage_built(player, FAILLE))
	assert_false(PostTakeover.passage_works(player, FAILLE))


func test_a_takeover_cancels_the_reinforcements_going_below_and_hands_the_post() -> void:
	var war := PostWar.new(CHEMINEE)
	var owner := war.owner()
	var at := GridPosition.new(0, 0)
	var below := ReinforcementOrder.new(2, 3, {UnitType.Value.SCOUT: 1}, 11, at)
	var elsewhere := ReinforcementOrder.new(1, 2, {UnitType.Value.SCOUT: 2}, 11, at)
	owner.pending_reinforcements.assign([below, elsewhere])
	war.put(owner, 3, {UnitType.Value.GUARDIAN: 4, UnitType.Value.SCOUT: 1})

	var lost := PostTakeover.apply(war.post, war.attacker(), owner)

	assert_eq(lost.units, {UnitType.Value.SCOUT: 1, UnitType.Value.GUARDIAN: 4})
	assert_eq(owner.pending_reinforcements, [elsewhere] as Array[ReinforcementOrder])
	assert_eq(owner.unit_counts_on_level(3), {} as Dictionary[UnitType.Value, int])
	assert_eq(Building.level_in(owner.buildings, CAPSULE), 0)
	assert_eq(war.post.captured_by, war.attacker().id)


func test_without_attacker_the_guardians_take_the_post_back() -> void:
	var war := PostWar.new(FAILLE)
	war.owner().buildings.erase(MODULE)

	var lost := PostTakeover.apply(war.post, null, war.owner())

	assert_null(war.post.captured_by)
	assert_false(lost.passage)
	assert_eq(lost.units, {} as Dictionary[UnitType.Value, int])
	var none := PostLoss.none()
	assert_eq([none.units, none.passage], [{}, false])
