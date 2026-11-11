extends TestCase
## test/domain/script/strategies/hunt_under_raid_test.dart: a faction clears
## the lairs it beats even under a raid, a player does not.

var _game: Game
var _lair: GridPosition


## A game at turn 20 where a raid is announced, a weak lair lies in sight of
## the base and the home army is strong.
func before_each() -> void:
	super()
	_game = GameFactory.new_single_player("Nemo", 3)
	_game.turn = 20
	var player := _game.human_player()
	var map: GameMap = _game.levels[1]
	for p: GridPosition in player.revealed_cells_on_level(1):
		if map.cell_at(p.x, p.y).content == CellContentType.Value.EMPTY:
			_lair = p
			break
	map.set_cell(_lair.x, _lair.y, map.cell_at(_lair.x, _lair.y).copy_with({
		"content": CellContentType.Value.MONSTER_LAIR,
		"lair": _weak_lair(),
	}))
	player.units_on_level(1)[UnitType.Value.HARPOONIST].count = 200
	player.raid_state.announce(_weak_lair(), 22)


static func _weak_lair() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 2, MonsterFamily.Value.SWARM)


func _cleared() -> bool:
	return _game.levels[1].cell_at(_lair.x, _lair.y).is_collected()


func test_a_player_leaves_the_lairs_alone_while_a_raid_is_announced() -> void:
	ConquestStrategy.new().play_turn(EventMoveSamples.script_turn_of(_game))
	assert_false(_cleared())


func test_a_faction_clears_the_lairs_it_beats_even_under_a_raid() -> void:
	var strategy := ConquestStrategy.new(null, 0.5, true, true, true, true, false, true)
	strategy.play_turn(EventMoveSamples.script_turn_of(_game))
	assert_true(_cleared())
