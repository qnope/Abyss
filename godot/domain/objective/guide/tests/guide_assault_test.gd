extends TestCase
## Not in the Dart files: lib/domain/objective/guide/guide_assault.dart has
## no test of its own, its advice is read through GuideCampaign
## (guide_campaign_assault_test.dart), ported too. Each
## branch, on the game of SiegeSamples: a Faille nobody
## holds on (1, 1) of level 1.

const Target := AssaultTarget.Value
const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const BARRACKS := BuildingType.Value.BARRACKS


func _advice(game: Game, target: Target) -> GuideAdvice:
	return GuideAssault.of(game, game.human_player(), target)


func test_the_levels_of_the_targets() -> void:
	assert_eq([GuideAssault.level_of(Target.FAILLE), GuideAssault.level_of(Target.CHEMINEE),
		GuideAssault.level_of(Target.KERNEL)], [1, 2, 3])


func test_without_admiral_the_barracks_then_the_admiral() -> void:
	var game := SiegeSamples.attack_game()
	var needed := UnitCostCalculator.new().unlock_level(ADMIRAL)
	var advice := _advice(game, Target.FAILLE)
	assert_true(advice.message is GuideAdmiralNeedsBarracks)
	var barracks: GuideAdmiralNeedsBarracks = advice.message
	assert_eq([barracks.target, barracks.barracks_level], [Target.FAILLE, needed])
	assert_true(advice.target.equals(GuideTarget.for_building(BARRACKS)))
	game.human_player().buildings[BARRACKS].level = needed
	advice = _advice(game, Target.KERNEL)
	assert_true(advice.message is GuideAdmiralToRecruit)
	assert_true(advice.target.equals(GuideTarget.for_unit(ADMIRAL)))


func test_an_admiral_above_the_level_is_sent_down_through_a_post_held() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1})
	var advice := _advice(game, Target.CHEMINEE)
	assert_true(advice.message is GuideAdmiralToSend)
	var send: GuideAdmiralToSend = advice.message
	assert_eq([send.target, send.level, send.from], [Target.CHEMINEE, 2, 1])
	assert_true(advice.target.equals(GuideTarget.for_map()))
	var map: GameMap = game.levels[1]
	map.cell_at(1, 1).transition_base.captured_by = game.human_player_id
	advice = _advice(game, Target.CHEMINEE)
	assert_true(advice.target.equals(GuideTarget.for_cell(1, GridPosition.new(1, 1))))


func test_an_admiral_on_the_level_looks_for_the_post_then_takes_it() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, UnitType.Value.GUARDIAN: 2})
	var advice := _advice(game, Target.FAILLE)
	assert_true(advice.message is GuidePostToFind)
	assert_true(advice.target.equals(GuideTarget.for_map()))
	game.human_player().add_revealed_cell(1, GridPosition.new(1, 1))
	advice = _advice(game, Target.FAILLE)
	assert_true(advice.message is GuidePostAssault)
	var assault: GuidePostAssault = advice.message
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, UnitType.Value.GUARDIAN: 2}
	var plan := AssaultPlan.of(game.human_player(), 1, Target.FAILLE, army)
	assert_eq(assault.harpoonists, plan.suggested_harpoonists())
	assert_true(advice.target.equals(GuideTarget.for_cell(1, GridPosition.new(1, 1))))


func test_the_admiral_fell_in_an_assault_won_this_turn() -> void:
	var game := SiegeSamples.attack_game()
	game.turn = 5
	var p := game.human_player()
	assert_false(GuideAssault.admiral_fell(game, p, Target.FAILLE))
	p.add_history_entry(_capture(4, "faille:0", false))
	assert_false(GuideAssault.admiral_fell(game, p, Target.FAILLE))
	p.add_history_entry(_capture(5, "faille:0", true))
	p.add_history_entry(_capture(5, "no post", false))
	assert_false(GuideAssault.admiral_fell(game, p, Target.FAILLE))
	p.add_history_entry(_capture(5, "cheminee:1", false))
	assert_true(GuideAssault.admiral_fell(game, p, Target.CHEMINEE))
	assert_false(GuideAssault.admiral_fell(game, p, Target.FAILLE))
	p.add_history_entry(_capture(5, CaptureEntry.VOLCANIC_KERNEL, false))
	assert_true(GuideAssault.admiral_fell(game, p, Target.KERNEL))
	p.add_history_entry(HistorySamples.raid_entry(true))
	p.history_entries[-1].turn = 5
	assert_true(GuideAssault.admiral_fell(game, p, Target.KERNEL))


func _capture(turn: int, name: String, captured: bool) -> CaptureEntry:
	return CaptureEntry.new(turn, name, HistorySamples.fight(true), captured)


func test_the_walk_back_stops_at_the_first_entry_of_an_earlier_turn() -> void:
	var game := SiegeSamples.attack_game()
	game.turn = 5
	var p := game.human_player()
	p.add_history_entry(_capture(5, "faille:0", false))
	assert_true(GuideAssault.admiral_fell(game, p, Target.FAILLE))
	p.add_history_entry(_capture(4, "cheminee:0", true))
	assert_false(GuideAssault.admiral_fell(game, p, Target.FAILLE))
