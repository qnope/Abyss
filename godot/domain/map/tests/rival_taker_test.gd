extends TestCase
## test/domain/map/rival_taker_test.dart: which faction emptied a cell before
## the human.

const NOMADS := FactionPersonality.Value.CURRENT_NOMADS

var _nomads := Faction.new(NOMADS)
var _human := Player.new("Nemo", null, 1, 1)
var _game: Game


func before_each() -> void:
	var rival := Player.new(_nomads.name(), _nomads.id(), 8, 8)
	_game = GameSamples.game([_human, rival])
	_game.saved_factions = [NOMADS]


func _lair_taken_by(id: Variant) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR, null, id)


func test_a_cell_taken_by_a_faction_names_that_faction() -> void:
	assert_eq(RivalTaker.of(_game, _lair_taken_by(_nomads.id())).personality, NOMADS)


func test_a_cell_the_human_took_has_no_rival_taker() -> void:
	assert_null(RivalTaker.of(_game, _lair_taken_by(_human.id)))


func test_a_cell_nobody_took_has_no_rival_taker() -> void:
	assert_null(RivalTaker.of(_game, _lair_taken_by(null)))


func test_a_cell_taken_by_an_unknown_player_has_no_rival_taker() -> void:
	assert_null(RivalTaker.of(_game, _lair_taken_by("someone")))


## Not in the Dart file: a faction of the game without its player is none.
func test_a_faction_whose_player_is_gone_has_no_rival_taker() -> void:
	_game.players.erase(_nomads.id())
	assert_null(RivalTaker.of(_game, _lair_taken_by(_nomads.id())))
