extends TestCase
## Not in the Dart files: FactionFall, which the Dart tests reach through
## the end of a turn (`faction_play_test.dart`, waiting for `turn`), and
## FactionSpyScout alone, which they reach through FactionWar.

const SCOUT := UnitType.Value.SCOUT


static func _game() -> Game:
	return GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2)


static func _faction(game: Game, i: int) -> Player:
	return game.players[game.factions()[i].id()]


func test_a_faction_falls_after_three_raids_lost_and_frees_its_posts() -> void:
	var war := KernelWar.new(9)
	var game := war.game
	var victim := war.owner()
	var post := _first_post(game)
	post.captured_by = victim.id
	victim.raid_state.lost_in_a_row = 2
	FactionFall.apply(game)
	assert_false(victim.has_fallen())
	victim.raid_state.lost_in_a_row = 3
	FactionFall.apply(game)
	assert_true(victim.has_fallen())
	assert_null(post.captured_by)
	assert_null(war.holder())
	assert_false(war.attacker().has_fallen())


func test_a_fallen_faction_and_a_missing_one_are_left_as_they_are() -> void:
	var war := KernelWar.new(9)
	var victim := war.owner()
	victim.raid_state.lost_in_a_row = 3
	victim.saved_fallen = true
	war.game.players.erase(war.attacker().id)
	FactionFall.apply(war.game)
	assert_eq(war.holder(), victim.id, "a fallen faction is not dropped twice")


func test_the_spy_scout_is_kept_home_with_what_the_exploration_needs() -> void:
	var game := _game()
	var me := _faction(game, 0)
	var p := game.factions()[0].personality
	AssaultSamples.set_level(me, BuildingType.Value.BARRACKS, 1)
	for r: ResourceType.Value in ResourceType.Value.values():
		me.resources[r].amount = 5000
	var turn := _turn(game, me)
	var wanted := ScoutMoves.scouts_wanted(
		turn, FactionTraits.of(p).explorers, FactionScouting.deep_scouts_of(p), true
	)
	assert_true(wanted > 0)
	FactionSpyScout.keep(turn, p)
	assert_eq(AssaultSamples.standing(me, SCOUT), wanted + 1)
	FactionSpyScout.keep(_turn(game, me), p)
	assert_eq(AssaultSamples.standing(me, SCOUT), wanted + 1, "one scout home is enough")


func test_a_poor_faction_keeps_the_one_spy_scout() -> void:
	var game := _game()
	var me := _faction(game, 0)
	AssaultSamples.station(me, {})
	AssaultSamples.set_level(me, BuildingType.Value.BARRACKS, 1)
	for r: ResourceType.Value in ResourceType.Value.values():
		me.resources[r].amount = 0
	me.resources[ResourceType.Value.ALGAE].amount = 10
	me.resources[ResourceType.Value.CORAL].amount = 5
	FactionSpyScout.keep(_turn(game, me), game.factions()[0].personality)
	assert_eq(AssaultSamples.standing(me, SCOUT), 1)


static func _turn(game: Game, me: Player) -> FactionTurn:
	return FactionTurn.new(game, me, ActionExecutor.new(), DartRandom.new(2, false))


static func _first_post(game: Game) -> TransitionBase:
	for cell: MapCell in game.levels[1].cells:
		if cell.transition_base != null:
			return cell.transition_base
	return null
