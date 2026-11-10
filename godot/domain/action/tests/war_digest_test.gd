extends TestCase
## Not in the Dart files: the wars between players on the games of
## GameFactory, as the Dart rules play them, read by a scratch script run
## with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, factionCount: 2, humanId: 'human'), the human's tutorial
## over. Posts: on turn 12 + 4k (k 0 to 3) the human attacks the first
## Faille of level 1 (k even) or Cheminée of level 2 (k odd), held by the
## first faction with its passage at 2, with 10 + 4k harpoonists and k
## guardians, the faction standing 3 + 3k guardians (20 more on k = 3) and
## 5 + 2k harpoonists below, the dice Random(seed + 200 + k); the last
## attack again, refused; then on turn 29 the second faction takes the
## human's Faille with 30 harpoonists and 5 guardians, Random(seed + 300).
## Compared with WarHistories.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT
const FAILLE := TransitionBaseType.Value.FAILLE


func _first_post(game: Game, kind: TransitionBaseType.Value, level: int) -> GridPosition:
	var map: GameMap = game.levels[level]
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base != null and base.type == kind:
				return GridPosition.new(x, y)
	return GridPosition.new(-1, -1)


func _put(p: Player, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for unit: Unit in KernelGarrison.stock_at(p, level).values():
		unit.count = units.get(unit.type, 0)


func _post(game: Game, level: int, at: GridPosition) -> TransitionBase:
	var map: GameMap = game.levels[level]
	return map.cell_at(at.x, at.y).transition_base


func _posts(game: Game, p: Player, rival: Player, other: Player, seed_: int) -> Array[String]:
	var lines: Array[String] = []
	var last: AttackPostAction
	for k: int in 4:
		var kind := FAILLE if k % 2 == 0 else TransitionBaseType.Value.CHEMINEE
		var level := 1 if k % 2 == 0 else 2
		var at := _first_post(game, kind, level)
		var post := _post(game, level, at)
		game.turn = 12 + 4 * k
		var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 10 + 4 * k}
		if k > 0:
			army[GUARDIAN] = k
		post.captured_by = rival.id
		var passage := PostTakeover.passage_of(kind)
		rival.buildings[passage] = Building.new(passage, 2)
		p.add_revealed_cell(level, at)
		_put(p, level, army)
		_put(rival, post.target_level(), {GUARDIAN: 3 + 3 * k + (20 if k == 3 else 0), HARPOONIST: 5 + 2 * k})
		last = AttackPostAction.new(at.x, at.y, level, army, DartRandom.new(seed_ + 200 + k))
		var r := ActionExecutor.new().execute(last, game, p)
		lines.append("%s | %s %d %s" % [
			WarDigests.assault(r, p, rival, level, post.target_level()), post.captured_by,
			rival.buildings[passage].level, WarDigests.turns(p.raid_state.post_attack_turns),
		])
	_post(game, 2, GridPosition.new(last.target_x, last.target_y)).captured_by = rival.id
	_put(p, 2, last.selected_units)
	var again := ActionExecutor.new().execute(last, game, p)
	lines.append(WarDigests.assault(again, p, rival, 2, 3))
	var at := _first_post(game, FAILLE, 1)
	var faille := _post(game, 1, at)
	faille.captured_by = p.id
	p.buildings[PostTakeover.passage_of(faille.type)].level = 2
	_put(p, 2, {GUARDIAN: 6, HARPOONIST: 4, SCOUT: 2})
	var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 30, GUARDIAN: 5}
	_put(other, 1, army)
	game.turn = 29
	var strike := AttackPostAction.new(at.x, at.y, 1, army, DartRandom.new(seed_ + 300))
	var r := ActionExecutor.new().execute(strike, game, other)
	lines.append("%s | %s %d" % [
		WarDigests.assault(r, other, p, 1, 2), faille.captured_by,
		p.buildings[PostTakeover.passage_of(faille.type)].level,
	])
	return lines


func test_the_wars_play_as_dart_plays_them_on_new_games() -> void:
	for seed_: int in [3, 11, 24]:
		var game := GameFactory.new_game("Nemo", seed_, Difficulty.Value.NORMAL, false, 2, null, "human")
		var p := game.human_player()
		ObjectiveMigration.state_of(game, p).tutorial_enabled = false
		var rival: Player = game.players[game.factions()[0].id()]
		var other: Player = game.players[game.factions()[1].id()]
		var lines := _posts(game, p, rival, other, seed_)
		var expected: Array = WarHistories.DIGESTS[str(seed_)]
		assert_eq(lines.size(), expected.size(), str(seed_))
		for i: int in mini(lines.size(), expected.size()):
			assert_eq(lines[i], expected[i], "%d %d" % [seed_, i])
