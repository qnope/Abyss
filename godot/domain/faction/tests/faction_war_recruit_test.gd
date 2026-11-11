extends TestCase
## test/domain/faction/faction_war_recruit_test.dart: a faction arms for war
## with its own mix once it knows a rival.

const Personality := FactionPersonality.Value
const R := ResourceType.Value


static func _new_game(p: Personality) -> Game:
	return GameFactory.new_game("Nemo", 3, Difficulty.Value.NORMAL, false, 0, [p] as Array[Personality])


static func _armed(game: Game, sees_human: bool) -> Player:
	var me: Player = game.players[game.factions()[0].id()]
	me.buildings[BuildingType.Value.BARRACKS].level = 5
	for r: R in R.values():
		me.resources[r].amount = 5000
	if sees_human:
		var human := game.human_player()
		me.add_revealed_cell(1, GridPosition.new(human.base_x, human.base_y))
	return me


static func _turn(game: Game, me: Player) -> ScriptTurn:
	return ScriptTurn.new(game, DartRandom.new(1), [], me)


static func _count(me: Player, type: UnitType.Value) -> int:
	return me.units_on_level(1)[type].count


func test_a_faction_that_knows_a_rival_arms_with_its_own_mix_of_units() -> void:
	var p := Personality.WRECK_PILLAGERS
	var game := _new_game(p)
	var me := _armed(game, true)
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	assert_true(_count(me, UnitType.Value.HARPOONIST) > 0)
	assert_true(_count(me, UnitType.Value.SABOTEUR) > 0)


func test_a_faction_alone_keeps_its_stocks_for_the_race() -> void:
	var p := Personality.WRECK_PILLAGERS
	var game := _new_game(p)
	var me := _armed(game, false)
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	assert_eq(_count(me, UnitType.Value.HARPOONIST), 0)


func test_it_keeps_what_it_spends_within_its_war_share_of_the_stocks() -> void:
	var p := Personality.PEARL_ORDER
	var game := _new_game(p)
	var me := _armed(game, true)
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	assert_true(me.resources[R.CORAL].amount > 4000)


## Not in the Dart file: a fallen rival, a share of nothing, a mix the
## barracks cannot train and a stock too poor arm nothing.
func test_nothing_to_arm_with_or_against_arms_nothing() -> void:
	var p := Personality.WRECK_PILLAGERS
	var game := _new_game(p)
	var me := _armed(game, true)
	game.human_player().saved_fallen = true
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	game.human_player().saved_fallen = false
	FactionWarRecruit.play(_turn(game, me), FactionTraits.new())
	me.buildings[BuildingType.Value.BARRACKS].level = 0
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	me.buildings[BuildingType.Value.BARRACKS].level = 5
	for r: R in R.values():
		me.resources[r].amount = 0
	FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p))
	assert_eq(_count(me, UnitType.Value.HARPOONIST), 0)
	assert_eq(me.recruited_unit_types.size(), 0)
