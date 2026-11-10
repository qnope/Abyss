extends TestCase
## test/domain/event/effects/wreck_effect_test.dart: where a wreck sinks and
## when it may be drawn. The check of 'no wreck is drawn when no hidden
## empty cell borders the area' on EventEffects.excludedAt waits for
## event_effects.dart, which waits for the predators (raid) and the
## survivors (volcano).

const WRECK := CellContentType.Value.WRECK

var _wreck := WreckEffect.new()


## Sinks a wreck at the end of turn 12 with the dice of `seed_value`.
func _sink(game: Game, player: Player, seed_value: int) -> GridPosition:
	_wreck.on_draw(game, player, 12, DartRandom.new(seed_value))
	return player.event_state.wreck_position


func _contents(ring: Array[GridPosition], content: CellContentType.Value, but: Variant = null) -> Dictionary[Vector2i, CellContentType.Value]:
	var contents: Dictionary[Vector2i, CellContentType.Value] = {}
	for p: GridPosition in ring:
		if not p.equals(but):
			contents[p.key()] = content
	return contents


func test_a_wreck_sinks_on_a_hidden_empty_cell_at_the_edge_of_the_explored_area_until_the_end_of_turn_17() -> void:
	var ring := GridPosition.keys(EventSamples.wreck_ring())
	for seed_value: int in 40:
		var player := EventSamples.wreck_player()
		var game := EventSamples.wreck_game(player)
		var at := _sink(game, player, seed_value)
		assert_has(ring, at.key(), "seed %d" % seed_value)
		assert_false(player.revealed_cells().has(at.key()))
		assert_eq(game.current_map().cell_at(at.x, at.y).content, WRECK)
		assert_eq(player.event_state.wreck_until_turn, 12 + EventRules.WRECK_TURNS)


func test_only_an_empty_cell_can_take_the_wreck() -> void:
	var free := GridPosition.new(6, 2)
	for seed_value: int in 10:
		var map := EventSamples.wreck_map(9, _contents(EventSamples.wreck_ring(), CellContentType.Value.RUINS, free))
		var player := EventSamples.wreck_player()
		assert_true(_sink(EventSamples.wreck_game(player, map), player, seed_value).equals(free))


func test_the_dice_pick_the_cell_whatever_the_order_of_the_revealed_cells() -> void:
	var picks := {}
	for seed_value: int in 40:
		var player := EventSamples.wreck_player()
		var at := _sink(EventSamples.wreck_game(player), player, seed_value)
		var square := EventSamples.square_around(4, 4, 1)
		square.reverse()
		var reversed := EventSamples.wreck_player(square)
		assert_true(_sink(EventSamples.wreck_game(reversed), reversed, seed_value).equals(at))
		picks[at.key()] = true
	assert_true(picks.size() > 5)


func test_a_wreck_never_sinks_on_a_cell_the_scouts_may_not_explore() -> void:
	var base := GridPosition.new(4, 4)
	var ring := EventSamples.square_around(4, 4, 1)
	ring.remove_at(4)
	for seed_value: int in 40:
		var player := EventSamples.wreck_player(ring)
		assert_false(_sink(EventSamples.wreck_game(player), player, seed_value).equals(base))


func test_a_wreck_sinks_with_the_dice_of_the_draw() -> void:
	var player := EventSamples.wreck_player()
	var random := DartRandom.new(5)
	_wreck.on_draw(EventSamples.wreck_game(player), player, 12, random)
	assert_ne(random.next_int(1000), DartRandom.new(5).next_int(1000))


func test_no_wreck_is_drawn_when_no_hidden_empty_cell_borders_the_area() -> void:
	var player := EventSamples.wreck_player()
	var full := EventSamples.wreck_map(9, _contents(EventSamples.wreck_ring(), CellContentType.Value.MONSTER_LAIR))
	assert_false(_wreck.allowed_at(EventSamples.wreck_game(player, full), player, 12))
	assert_true(_wreck.allowed_at(EventSamples.wreck_game(player), player, 12))


func test_no_wreck_is_drawn_on_a_fully_explored_map() -> void:
	var player := EventSamples.wreck_player(EventSamples.square_around(4, 4, 4))
	assert_false(_wreck.allowed_at(EventSamples.wreck_game(player), player, 12))


func test_no_second_wreck_is_drawn_while_one_lies_on_the_map() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player)
	_sink(game, player, 1)
	assert_false(_wreck.allowed_at(game, player, 14))


func test_the_wreck_borders_a_wide_explored_area_on_a_large_map() -> void:
	const SIZE := 120
	var revealed: Array[GridPosition] = []
	for y: int in SIZE:
		for x: int in SIZE - 2:
			revealed.append(GridPosition.new(x, y))
	var player := EventSamples.wreck_player(revealed)
	var game := EventSamples.wreck_game(player, EventSamples.wreck_map(SIZE))
	assert_eq(_sink(game, player, 3).x, SIZE - 2)
