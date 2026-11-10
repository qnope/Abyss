extends TestCase
## Not in the Dart tests, which read CapturedBaseFinder through the
## reinforcements and the descent (the action module): the post of a level
## a player holds, as lib/domain/map/captured_base_finder.dart answers.


func test_finds_the_post_a_player_holds_with_its_cell() -> void:
	var game := _game({1: _map_with([[2, 1, "other"], [0, 2, "p"], [1, 2, "p"]])})
	var found := CapturedBaseFinder.on(game, 1, "p")
	assert_eq(found.position.key(), Vector2i(0, 2))
	assert_eq(found.base.captured_by, "p")


func test_finds_nothing_on_an_unknown_level_or_without_a_post_held() -> void:
	var game := _game({1: _map_with([[2, 1, "other"], [1, 1, null]])})
	assert_null(CapturedBaseFinder.on(game, 1, "p"))
	assert_null(CapturedBaseFinder.on(game, 2, "p"))


## A 3x3 map with a Faille at each [x, y, holder] given.
func _map_with(posts: Array) -> GameMap:
	var map := MapSamples.plain_map(3, 3)
	for post: Array in posts:
		var x: int = post[0]
		var y: int = post[1]
		var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille", post[2])
		map.set_cell(x, y, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base))
	return map


func _game(levels: Dictionary[int, GameMap]) -> Game:
	return Game.new("p", {"p": GameSamples.player("p")}, 1, levels)
