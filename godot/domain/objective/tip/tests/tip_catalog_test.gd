extends TestCase
## test/domain/objective/tip/tip_catalog_test.dart: every tip card, and the
## one to open next.

const Id := TipId.Value
const Category := TipCategory.Value
const STORM := RandomEventType.Value.STORM

var game: Game


func before_each() -> void:
	game = ObjectiveSamples.objective_game()
	game.human_player().saved_objective_state = ObjectiveState.new([], false, true)


func _state() -> ObjectiveState:
	return game.human_player().saved_objective_state


func _next() -> Variant:
	var tip := TipCatalog.next_for(game, game.human_player())
	return null if tip == null else tip.id


func _pending() -> Array:
	var ids: Array = []
	for tip: Tip in TipCatalog.pending_for(game, game.human_player()):
		ids.append(tip.id)
	return ids


func _storm_and_noise() -> void:
	game.human_player().event_state.record_draw(STORM)
	game.human_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))


func test_tip_catalog_holds_one_tip_per_id_in_the_order_of_the_ids() -> void:
	var ids: Array = []
	for tip: Tip in TipCatalog.all():
		ids.append(tip.id)
	assert_eq(ids, Id.values())


func test_tip_catalog_files_each_tip_in_its_section_of_the_guide() -> void:
	assert_eq(TipCatalog.by_id(Id.NOISE_GAUGE).category, Category.BASE)
	assert_eq(TipCatalog.by_id(Id.LAST_CHANCE).category, Category.THREATS)
	assert_eq(TipCatalog.by_id(Id.DESCENT).category, Category.MAP)
	assert_eq(TipCatalog.by_id(Id.STORM).category, Category.EVENTS)


func test_tip_catalog_one_tip_per_event_in_the_events_section() -> void:
	var ids: Dictionary[Id, bool] = {}
	for type: RandomEventType.Value in RandomEventType.Value.values():
		ids[EventTips.id_of(type)] = true
	assert_eq(ids.size(), RandomEventType.Value.size())
	for id: Id in ids:
		assert_eq(TipCatalog.by_id(id).category, Category.EVENTS)


func test_pending_for_every_unseen_tip_that_applies_in_catalog_order() -> void:
	_storm_and_noise()
	assert_eq(_pending(), [Id.NOISE_GAUGE, Id.EVENTS, EventTips.id_of(STORM)])


func test_pending_for_skips_the_seen_ones_none_when_the_tips_are_off() -> void:
	_storm_and_noise()
	_state().mark_seen(Id.NOISE_GAUGE)
	assert_eq(_pending()[0], Id.EVENTS)
	_state().tips_enabled = false
	assert_eq(_pending(), [])


func test_next_for_none_while_no_situation_calls_for_a_tip() -> void:
	assert_null(_next())


func test_next_for_the_tip_whose_situation_is_there() -> void:
	game.human_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))
	assert_eq(_next(), Id.NOISE_GAUGE)


func test_next_for_the_first_one_in_catalog_order_when_several_apply() -> void:
	_storm_and_noise()
	assert_eq(_next(), Id.NOISE_GAUGE)


func test_next_for_skips_the_tips_already_seen() -> void:
	_storm_and_noise()
	_state().mark_seen(Id.NOISE_GAUGE)
	assert_eq(_next(), Id.EVENTS)
	_state().mark_seen(Id.EVENTS)
	assert_eq(_next(), EventTips.id_of(STORM))
	_state().mark_seen(EventTips.id_of(STORM))
	assert_null(_next())


func test_next_for_none_when_the_tips_are_switched_off() -> void:
	game.human_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))
	_state().tips_enabled = false
	assert_null(_next())


## Not in the Dart file: the categories by their Dart names, in order.
func test_the_categories_have_the_dart_names_and_order() -> void:
	assert_eq(
		DartEnum.names(Category), PackedStringArray(["base", "threats", "map", "events", "archives"])
	)
