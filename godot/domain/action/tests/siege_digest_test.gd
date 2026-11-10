extends TestCase
## Not in the Dart files: the assaults on the volcanic kernel and the
## takeovers of a kernel and of a post on the games of GameFactory, as the
## Dart rules play them, read by a scratch script run with `dart run` on
## lib/domain. GameFactory.newGame(playerName: 'Nemo', mapSeed: seed,
## factionCount: 2, humanId: 'human'). Assault k (0 to 5) is made on turn
## k + 1 through ActionExecutor, the kernel freed first, with 1 + k % 2
## admirals, 60 + 40k Dome Breakers, 3k guardians from k = 2, none of the
## scouts on k = 4, the dice Random(seed * 10 + k); a seventh, without
## admiral, is refused. Then on turn 9 the rival takes the kernel the human
## holds at level 2 with a garrison (down to 1, then 0), and the first
## Faille of level 1, compared with SiegeHistories.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const BREAKER := UnitType.Value.DOME_BREAKER
const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT


func _first(map: GameMap, ok: Callable) -> GridPosition:
	for y: int in map.height:
		for x: int in map.width:
			if ok.call(x, y):
				return GridPosition.new(x, y)
	return GridPosition.new(-1, -1)


func _put(p: Player, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for unit: Unit in KernelGarrison.stock_at(p, level).values():
		unit.count = units.get(unit.type, 0)


func _counts(map: Dictionary) -> String:
	return HistoryDigests.counts(map, UnitType.Value)


func _strike(game: Game, p: Player, at: GridPosition, army: Dictionary[UnitType.Value, int], seed_: int) -> String:
	var map: GameMap = game.levels[3]
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": null}))
	_put(p, 3, army)
	var action := AttackVolcanicKernelAction.new(at.x, at.y, 3, army, DartRandom.new(seed_))
	var r := ActionExecutor.new().execute(action, game, p)
	if not r.is_success:
		var reason: int = r.reason
		return DartEnum.name_of(ActionFailure.Value, reason)
	var k: AttackVolcanicKernelResult = r
	var f := k.fight
	var entry := "-"
	if not p.history_entries.is_empty() and p.history_entries[-1] is CaptureEntry:
		var last: CaptureEntry = p.history_entries[-1]
		entry = "%d %s %s" % [last.turn, last.transition_base_name, last.captured]
	return "%s%s %s %d %d>%d | %s | %s | %s | %s | %s | %s n%d h%d %s" % [
		"V" if k.victory else "L", "C" if k.captured else "-", DartEnum.name_of(CombatSide.Value, f.winner),
		f.turn_count, f.initial_monster_count, f.final_monster_count, _counts(k.sent),
		_counts(k.survivors_intact), _counts(k.wounded), _counts(k.dead), _counts(p.unit_counts_on_level(3)),
		_holder(map, at), p.raid_state.noise, p.history_entries.size(), entry,
	]


func _holder(map: GameMap, at: GridPosition) -> String:
	var id: Variant = map.cell_at(at.x, at.y).collected_by
	return "null" if id == null else str(id)


func _takeovers(game: Game, p: Player, rival: Player, at: GridPosition) -> Array[String]:
	var lines: Array[String] = []
	var volcano: GameMap = game.levels[3]
	p.buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(BuildingType.Value.VOLCANIC_KERNEL, 2)
	_put(p, KernelGarrison.STOCK_KEY, {GUARDIAN: 2, HARPOONIST: 5})
	game.turn = 9
	for after: int in [1, 0]:
		var lost := KernelTakeover.apply(game, at.x, at.y, rival, p, after)
		lines.append("kernel %d %s | %d %s %s" % [
			after, _counts(lost), KernelGarrison.of(p).size(), _holder(volcano, at), p.raid_state.kernel_siege_lost_turn,
		])
	var level_one: GameMap = game.levels[1]
	var pos := _first(level_one, func(x: int, y: int) -> bool: return level_one.cell_at(x, y).transition_base != null)
	var post := level_one.cell_at(pos.x, pos.y).transition_base
	post.captured_by = "human"
	var passage := PostTakeover.passage_of(post.type)
	p.buildings[passage].level = 1
	_put(p, post.target_level(), {SCOUT: 2, HARPOONIST: 4})
	p.pending_reinforcements.append_array([
		ReinforcementOrder.new(1, post.target_level(), {SCOUT: 1}, 8, pos),
		ReinforcementOrder.new(post.target_level(), 3, {SCOUT: 1}, 8, pos),
	])
	var loss := PostTakeover.apply(post, rival, p)
	lines.append("post %s %s %s | %d %d %s" % [
		DartEnum.name_of(TransitionBaseType.Value, post.type), _counts(loss.units), loss.passage,
		p.buildings[passage].level, p.pending_reinforcements.size(), post.captured_by == rival.id,
	])
	return lines


func test_the_sieges_play_as_dart_plays_them_on_new_games() -> void:
	for seed_: int in [3, 11, 24]:
		var game := GameFactory.new_game("Nemo", seed_, Difficulty.Value.NORMAL, false, 2, null, "human")
		var p := game.human_player()
		var rival: Player = game.players[game.factions()[0].id()]
		var volcano: GameMap = game.levels[3]
		var at := _first(volcano, func(x: int, y: int) -> bool:
			return volcano.cell_at(x, y).content == CellContentType.Value.VOLCANIC_KERNEL)
		var lines: Array[String] = []
		for k: int in 6:
			game.turn = 1 + k
			var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1 + k % 2, BREAKER: 60 + 40 * k}
			if k > 1:
				army[GUARDIAN] = 3 * k
			if k == 4:
				army[SCOUT] = 0
			lines.append(_strike(game, p, at, army, seed_ * 10 + k))
		lines.append(_strike(game, p, at, {BREAKER: 9}, seed_))
		lines.append_array(_takeovers(game, p, rival, at))
		var expected: Array = SiegeHistories.DIGESTS[str(seed_)]
		assert_eq(lines.size(), expected.size(), str(seed_))
		for i: int in lines.size():
			assert_eq(lines[i], expected[i], "%d %d" % [seed_, i])
