extends VectorTestCase
## reference/vectors/map_rules.json: the small rules a map is generated and
## explored with, as the Dart rules answer.

var _vectors := VectorFile.new("map_rules")


func test_layout() -> void:
	var cases := _vectors.cases("layout")
	assert_eq(cases.size(), 11, "1 to 11 players")
	for case: Dictionary in cases:
		var players: int = case["players"]
		var size := MapLayout.size_for(players)
		var lairs := MapLayout.lair_range_for(size)
		var out := {
			"size": size,
			"extraPosts": MapLayout.extra_posts_for(players),
			"lairs": [lairs.x, lairs.y],
		}
		assert_same(out, case["out"], str(case))


func test_lair_family() -> void:
	var cases := _vectors.cases("lairFamily")
	assert_eq(cases.size(), 18)
	for case: Dictionary in cases:
		var seed_of_case: int = case["seed"]
		var level: int = case["level"]
		var cells: Array = case["cells"]
		var families: Array[MonsterFamily.Value] = []
		for cell: int in cells:
			families.append(LairBuilder.family_for(seed_of_case, cell, level))
		var names := VectorInputs.names(MonsterFamily.Value, families)
		assert_same(names, case["out"], "seed %d, level %d" % [seed_of_case, level])


func test_lair() -> void:
	var cases := _vectors.cases("lair")
	assert_eq(cases.size(), 30)
	for case: Dictionary in cases:
		var seed_of_case: int = case["seed"]
		var family_seed: int = case["familySeed"]
		var cell: int = case["cell"]
		var difficulty := (
			VectorInputs.value(MonsterDifficulty.Value, case["difficulty"])
			as MonsterDifficulty.Value
		)
		var lair := LairBuilder.build(difficulty, DartRandom.new(seed_of_case), family_seed, cell)
		var out := [
			DartEnum.name_of(MonsterDifficulty.Value, lair.difficulty),
			VectorInputs.name_or_null(MonsterFamily.Value, lair.family),
			lair.unit_count,
			lair.level(),
			lair.total_count(),
		]
		assert_same(out, case["out"], str(case))


func test_starting_bases() -> void:
	var cases := _vectors.cases("startingBases")
	assert_eq(cases.size(), 42)
	for case: Dictionary in cases:
		var size: int = case["size"]
		var count: int = case["count"]
		var seed_of_case: int = case["seed"]
		var first_x: int = case["first"][0]
		var first_y: int = case["first"][1]
		var bases := StartingBasePlacer.place(
			size, GridPosition.new(first_x, first_y), count, DartRandom.new(seed_of_case)
		)
		assert_same(_pairs(GridPosition.keys(bases)), case["out"], str(case))


func test_reveal() -> void:
	var cases := _vectors.cases("reveal")
	assert_eq(cases.size(), 24)
	for case: Dictionary in cases:
		var x: int = case["x"]
		var y: int = case["y"]
		var side: int = case["side"]
		var revealed := RevealAreaCalculator.cells_to_reveal(x, y, side, 20, 20)
		assert_same(_pairs(GridPosition.keys(revealed)), case["out"], str(case))
		if side == RevealAreaCalculator.BASE_SIDE:
			var around := RevealAreaCalculator.around_base(x, y, 20, 20)
			assert_same(_pairs(GridPosition.keys(around)), case["out"], str(case))


func test_posts() -> void:
	var cases := _vectors.cases("posts")
	assert_eq(cases.size(), 6)
	for case: Dictionary in cases:
		var type := (
			VectorInputs.value(TransitionBaseType.Value, case["type"]) as TransitionBaseType.Value
		)
		var extra: int = case["extra"]
		var names := TransitionBaseName.all_of(type, extra)
		var post := TransitionBase.new(type, names[0].code())
		var out := {
			"codes": names.map(func(name: TransitionBaseName) -> String: return name.code()),
			"difficulty": post.difficulty(),
			"pearlsPerTurn": post.pearls_per_turn(),
			"targetLevel": post.target_level(),
		}
		assert_same(out, case["out"], str(case))


func test_volcano() -> void:
	var cases := _vectors.cases("volcano")
	assert_eq(cases.size(), 3)
	for case: Dictionary in cases:
		var x: int = case["x"]
		var y: int = case["y"]
		assert_same(_pairs(VolcanicKernelPlacer.footprint(x, y)), case["out"], str(case))


## Cells as a case writes them: [x, y].
func _pairs(cells: Array[Vector2i]) -> Array:
	return cells.map(func(cell: Vector2i) -> Array: return [cell.x, cell.y])
