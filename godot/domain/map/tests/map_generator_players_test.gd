extends TestCase
## test/domain/map/map_generator_players_test.dart, group 'MapGenerator with
## several players': a map grows with the number of players and gives each
## a base. Dart generates the tests of each number of players and seed in
## loops: each is one test that loops here. The group
## 'WorldGenerator.generate' is map_generator_players_world_test.gd.

## The side of the map by the number of players.
const SIZES: Dictionary[int, int] = {1: 20, 2: 20, 3: 20, 4: 26, 6: 26, 7: 32, 11: 32}
const SEEDS: Array[int] = [1, 42, 777]
const Content := CellContentType.Value


func test_a_lone_player_has_one_base_the_first_one() -> void:
	var r := MapGenerator.generate(5)
	assert_eq(GridPosition.keys(r.bases), [Vector2i(r.base_x, r.base_y)])


func test_each_seed_map_is_of_the_size_of_its_players() -> void:
	for players: int in SIZES:
		for seed_of_map: int in SEEDS:
			var r := MapGenerator.generate(seed_of_map, 1, {}, players)
			var size := SIZES[players]
			assert_eq([r.map.width, r.map.height, r.map.cells.size()], [size, size, size * size])


func test_each_seed_one_base_per_player_the_first_leading() -> void:
	for players: int in SIZES:
		for seed_of_map: int in SEEDS:
			var r := MapGenerator.generate(seed_of_map, 1, {}, players)
			var keys := GridPosition.keys(r.bases)
			assert_eq(keys.size(), players)
			assert_eq(keys[0], Vector2i(r.base_x, r.base_y))
			var distinct: Dictionary[Vector2i, bool] = {}
			for key: Vector2i in keys:
				distinct[key] = true
			assert_eq(distinct.size(), players)


func test_each_seed_bases_are_well_apart() -> void:
	for players: int in SIZES:
		var minimum := 7 if players <= 2 else 5
		for seed_of_map: int in SEEDS:
			var bases := MapGenerator.generate(seed_of_map, 1, {}, players).bases
			for i: int in players:
				for j: int in range(i + 1, players):
					var a := bases[i]
					var b := bases[j]
					var apart := MapSamples.chebyshev(a.x, a.y, b.x, b.y)
					assert_true(apart >= minimum, "%s and %s" % [a, b])


func test_each_seed_bases_sit_on_empty_cells_off_the_centre() -> void:
	for players: int in SIZES:
		var centre := DartMath.trunc_div(SIZES[players], 2)
		for seed_of_map: int in SEEDS:
			var r := MapGenerator.generate(seed_of_map, 1, {}, players)
			for index: int in r.bases.size():
				var b := r.bases[index]
				var cell := r.map.cell_at(b.x, b.y)
				assert_eq(cell.content, Content.EMPTY)
				assert_null(cell.lair)
				assert_null(cell.transition_base)
				if index > 0:
					assert_ne(b.key(), Vector2i(centre, centre))


func test_each_seed_no_lair_within_2_cells_of_any_base() -> void:
	for players: int in SIZES:
		var size := SIZES[players]
		for seed_of_map: int in SEEDS:
			var r := MapGenerator.generate(seed_of_map, 1, {}, players)
			for b: GridPosition in r.bases:
				for y: int in range(maxi(b.y - 2, 0), mini(b.y + 3, size)):
					for x: int in range(maxi(b.x - 2, 0), mini(b.x + 3, size)):
						assert_ne(r.map.cell_at(x, y).content, Content.MONSTER_LAIR)


func test_each_seed_enough_failles_lairs_scale_with_the_map() -> void:
	for players: int in SIZES:
		var extra := DartMath.trunc_div(players - 1, 2)
		for seed_of_map: int in SEEDS:
			var r := MapGenerator.generate(seed_of_map, 1, {}, players)
			assert_eq(_count(r, TransitionBaseType.Value.FAILLE), 4 + extra)
			assert_true(MapSamples.indices_of(r.map.cells, Content.MONSTER_LAIR).size() >= 5)


func test_each_number_of_players_is_deterministic_by_seed() -> void:
	for players: int in SIZES:
		var a := MapGenerator.generate(9, 1, {}, players)
		var b := MapGenerator.generate(9, 1, {}, players)
		assert_eq(MapSamples.fingerprint(a.map), MapSamples.fingerprint(b.map))
		assert_eq(GridPosition.keys(a.bases), GridPosition.keys(b.bases))


func test_one_more_cheminee_per_two_more_players_on_level_2() -> void:
	for players: int in [1, 2, 4, 7, 11]:
		var r := MapGenerator.generate(3, 2, {}, players)
		var expected := 3 + DartMath.trunc_div(players - 1, 2)
		assert_eq(_count(r, TransitionBaseType.Value.CHEMINEE), expected)


## Dart throws an ArgumentError: the port logs an error and gives no map.
func test_rejects_a_player_count_off_the_1_to_11_range() -> void:
	expect_error("MapLayout: playerCount 0 must be 1 to 11")
	assert_null(MapGenerator.generate(1, 1, {}, 0))
	expect_error("MapLayout: playerCount 12 must be 1 to 11")
	assert_null(MapGenerator.generate(1, 1, {}, 12))


## The cells that hold a post of the type, under any content.
func _count(r: MapGenerationResult, type: TransitionBaseType.Value) -> int:
	var count := 0
	for cell: MapCell in r.map.cells:
		if cell.transition_base != null and cell.transition_base.type == type:
			count += 1
	return count
