extends TestCase
## Not in the Dart files: what tip_catalog_test.dart checks of the catalog,
## which waits for the tips of the posts (`action`), checked on the lists
## ported: each tip in its section of the Guide, in the order of the ids,
## one tip per event.

const Id := TipId.Value
const Category := TipCategory.Value


func test_the_categories_have_the_dart_names_and_order() -> void:
	assert_eq(
		DartEnum.names(Category), PackedStringArray(["base", "threats", "map", "events", "archives"])
	)


func test_each_list_files_its_tips_in_its_section_in_the_order_of_the_ids() -> void:
	_expect(BaseTips.base_tips(), [Id.NOISE_GAUGE, Id.WORKSITES, Id.TECH_CHOICE], [Category.BASE])
	_expect(
		ThreatTips.threat_tips(),
		[Id.RAID_ANNOUNCED, Id.RAID_REPORT, Id.LAST_CHANCE, Id.MONSTER_FAMILIES, Id.VOLCANO_WAVE, Id.FACTION_ATTACK],
		[Category.THREATS],
	)
	_expect(MapTips.map_tips(), [Id.LAIR, Id.CHEST_AND_RUINS, Id.TRANSITION_BASE, Id.DESCENT], [Category.MAP])
	var events: Array = [Id.EVENTS, Id.WARM_CURRENT, Id.WRECK, Id.PREDATORS, Id.STORM]
	events.append_array([Id.SURVIVORS, Id.CARAVAN, Id.COLD_CURRENT])
	_expect(EventTips.all(), events, [Category.EVENTS])


func test_one_tip_per_event_in_the_events_section() -> void:
	var ids: Dictionary[Id, bool] = {}
	for type: RandomEventType.Value in RandomEventType.Value.values():
		ids[EventTips.id_of(type)] = true
		var tip := ObjectiveSamples.tip(EventTips.id_of(type))
		assert_eq(tip.category, Category.EVENTS)
	assert_eq(ids.size(), RandomEventType.Value.size())


func test_a_tip_applies_through_its_trigger() -> void:
	var game := ObjectiveSamples.objective_game()
	var seen: Array = []
	var tip := Tip.new(Id.LAIR, Category.MAP, func(g: Game, p: Player) -> bool:
		seen.append([g, p])
		return true)
	assert_true(tip.applies_to(game, game.human_player()))
	assert_eq(seen, [[game, game.human_player()]])


func _expect(tips: Array[Tip], ids: Array, categories: Array) -> void:
	var got_ids: Array = []
	for tip: Tip in tips:
		got_ids.append(tip.id)
		assert_has(categories, tip.category, DartEnum.name_of(Id, tip.id))
	assert_eq(got_ids, ids)
