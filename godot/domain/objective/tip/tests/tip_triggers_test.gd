extends TestCase
## test/domain/objective/tip/tip_triggers_test.dart: the situations of the
## tips of the base, the threats and the events, each tip read through
## TipCatalog.by_id (ObjectiveSamples.applies).

const Id := TipId.Value

var game: Game


func before_each() -> void:
	game = ObjectiveSamples.objective_game()


func test_base_tips_noise_gauge_once_the_gauge_is_a_quarter_full() -> void:
	_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4) - 1)
	assert_false(_applies(Id.NOISE_GAUGE))
	_player().raid_state.add_noise(1)
	assert_true(_applies(Id.NOISE_GAUGE))


func test_base_tips_worksites_once_the_hq_reaches_level_5() -> void:
	ObjectiveSamples.set_building(_player(), BuildingType.Value.HEADQUARTERS, 4)
	assert_false(_applies(Id.WORKSITES))
	ObjectiveSamples.set_building(_player(), BuildingType.Value.HEADQUARTERS, 5)
	assert_true(_applies(Id.WORKSITES))


func test_base_tips_tech_choice_once_the_node_2_of_a_branch_is_open() -> void:
	var branch := _player().tech_branches[TechBranch.Value.MILITARY]
	branch.unlocked = true
	assert_false(_applies(Id.TECH_CHOICE))
	branch.research_level = 1
	assert_true(_applies(Id.TECH_CHOICE))


func test_threat_tips_raid_announced_while_a_raid_is_coming() -> void:
	assert_false(_applies(Id.RAID_ANNOUNCED))
	_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 2), 12)
	assert_true(_applies(Id.RAID_ANNOUNCED))


func test_threat_tips_raid_report_after_the_first_raid_won_or_lost() -> void:
	assert_false(_applies(Id.RAID_REPORT))
	_player().raid_state.record_outcome(true)
	assert_true(_applies(Id.RAID_REPORT))
	game = ObjectiveSamples.objective_game()
	_player().raid_state.record_outcome(false)
	assert_true(_applies(Id.RAID_REPORT))


func test_threat_tips_last_chance_once_one_more_lost_raid_ends_the_game() -> void:
	_player().raid_state.record_outcome(false)
	assert_false(_applies(Id.LAST_CHANCE))
	_player().raid_state.record_outcome(false)
	assert_true(_applies(Id.LAST_CHANCE))


func test_threat_tips_volcano_wave_while_a_kraken_wave_is_coming() -> void:
	assert_false(_applies(Id.VOLCANO_WAVE))
	_player().volcano_state.announce(MonsterLair.new(MonsterDifficulty.Value.HARD, 5), 40)
	assert_true(_applies(Id.VOLCANO_WAVE))


func test_event_tips_events_once_a_first_event_is_drawn() -> void:
	assert_false(_applies(Id.EVENTS))
	_player().event_state.record_draw(RandomEventType.Value.STORM)
	assert_true(_applies(Id.EVENTS))


## Dart generates one test per event, `<type>: at its draw`.
func test_event_tips_each_event_at_its_draw() -> void:
	for type: RandomEventType.Value in RandomEventType.Value.values():
		game = ObjectiveSamples.objective_game()
		var id := EventTips.id_of(type)
		var other: RandomEventType.Value = RandomEventType.Value.WARM_CURRENT
		if type == other:
			other = RandomEventType.Value.WRECK
		var name := DartEnum.name_of(RandomEventType.Value, type)
		_player().event_state.record_draw(other)
		assert_false(_applies(id), name)
		_player().event_state.record_draw(type)
		assert_true(_applies(id), name)


func _player() -> Player:
	return game.human_player()


func _applies(id: Id) -> bool:
	return ObjectiveSamples.applies(game, id)
