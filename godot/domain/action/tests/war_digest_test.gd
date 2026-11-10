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
## Kernels: on turn 30 + 4k the human besieges the kernel the first faction
## holds at KERNEL_LEVELS[k], garrisoned by 2 + 3k guardians (25 more on
## k = 2) and 4 + 2k harpoonists, with 20 + 8k harpoonists and 2k
## guardians, Random(seed + 400 + k); then on turn 47 the second faction
## besieges the human's kernel at 1 with 40 harpoonists, Random(seed +
## 500), and again, refused. Compared with WarHistories.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT
const FAILLE := TransitionBaseType.Value.FAILLE
## The kernel levels of the four sieges.
const KERNEL_LEVELS: Array[int] = [2, 1, 3, 0]


func _first_post(game: Game, kind: TransitionBaseType.Value, level: int) -> GridPosition:
	var map: GameMap = game.levels[level]
	return WarDigests.first(map, func(x: int, y: int) -> bool:
		var base := map.cell_at(x, y).transition_base
		return base != null and base.type == kind)


func _put(p: Player, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	WarDigests.put(p, level, units)


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


func _hold(game: Game, at: GridPosition, owner: Player, level: int) -> void:
	var map: GameMap = game.levels[3]
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": owner.id}))
	owner.buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(BuildingType.Value.VOLCANIC_KERNEL, level)


func _kernels(game: Game, p: Player, rival: Player, other: Player, seed_: int) -> Array[String]:
	var lines: Array[String] = []
	var map: GameMap = game.levels[3]
	var at := WarDigests.first(map, func(x: int, y: int) -> bool:
		return map.cell_at(x, y).content == CellContentType.Value.VOLCANIC_KERNEL)
	var stock := KernelGarrison.STOCK_KEY
	p.add_revealed_cell(3, at)
	for k: int in 4:
		game.turn = 30 + 4 * k
		_hold(game, at, rival, KERNEL_LEVELS[k])
		_put(rival, stock, {GUARDIAN: 2 + 3 * k + (25 if k == 2 else 0), HARPOONIST: 4 + 2 * k})
		var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 20 + 8 * k}
		if k > 0:
			army[GUARDIAN] = 2 * k
		_put(p, 3, army)
		var strike := AttackHeldKernelAction.new(at.x, at.y, army, DartRandom.new(seed_ + 400 + k))
		lines.append(_kernel_line(ActionExecutor.new().execute(strike, game, p), p, rival, map, at))
	game.turn = 47
	_hold(game, at, p, 1)
	_put(p, stock, {GUARDIAN: 3, SCOUT: 1})
	var horde: Dictionary[UnitType.Value, int] = {HARPOONIST: 40}
	_put(other, 3, horde)
	var siege := AttackHeldKernelAction.new(at.x, at.y, horde, DartRandom.new(seed_ + 500))
	lines.append(_kernel_line(ActionExecutor.new().execute(siege, game, other), other, p, map, at))
	_hold(game, at, p, 1)
	_put(other, 3, horde)
	lines.append(WarDigests.assault(ActionExecutor.new().execute(siege, game, other), other, p, 3, stock))
	return lines


func _kernel_line(r: ActionResult, by: Player, owner: Player, map: GameMap, at: GridPosition) -> String:
	return "%s | %s %d %s %s" % [
		WarDigests.assault(r, by, owner, 3, KernelGarrison.STOCK_KEY), SiegeDigests.holder(map, at),
		KernelGarrison.kernel_level_of(owner), WarDigests.text(owner.raid_state.kernel_siege_lost_turn),
		WarDigests.turns(by.raid_state.kernel_attack_turns),
	]


func test_the_wars_play_as_dart_plays_them_on_new_games() -> void:
	for seed_: int in [3, 11, 24]:
		var game := GameFactory.new_game("Nemo", seed_, Difficulty.Value.NORMAL, false, 2, null, "human")
		var p := game.human_player()
		ObjectiveMigration.state_of(game, p).tutorial_enabled = false
		var rival: Player = game.players[game.factions()[0].id()]
		var other: Player = game.players[game.factions()[1].id()]
		var lines := _posts(game, p, rival, other, seed_)
		lines.append_array(_kernels(game, p, rival, other, seed_))
		var expected: Array = WarHistories.DIGESTS[str(seed_)]
		assert_eq(lines.size(), expected.size(), str(seed_))
		for i: int in mini(lines.size(), expected.size()):
			assert_eq(lines[i], expected[i], "%d %d" % [seed_, i])
