extends TestCase
## Not in the Dart files: 32 actions of every kind ported on the games of
## GameFactory, as the Dart rules take them, read by a scratch script run
## with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, difficulty, factionCount, humanId: 'human'); the human
## holds 20000 of each stock, a headquarters 5, a barracks 3, a laboratory 2
## and a descent module 1, has seen the 9x9 cells around its base and holds
## the first transition base of level 1. Action i is taken on turn i + 1
## through ActionExecutor, the dice one Random(seed); after each, the
## digest of ActionDigests, compared with ActionHistories.

const GAMES: Dictionary[String, Array] = {
	"solo-3": [3, Difficulty.Value.NORMAL, 0],
	"hard-11-three": [11, Difficulty.Value.HARD, 3],
	"easy-24-two": [24, Difficulty.Value.EASY, 2],
}
const LEVELS: Dictionary[BuildingType.Value, int] = {
	BuildingType.Value.HEADQUARTERS: 5, BuildingType.Value.BARRACKS: 3,
	BuildingType.Value.LABORATORY: 2, BuildingType.Value.DESCENT_MODULE: 1,
}


func _game(seed_: int, difficulty: Difficulty.Value, factions: int) -> Game:
	var game := GameFactory.new_game("Nemo", seed_, difficulty, false, factions, null, "human")
	var p := game.human_player()
	for resource: GameResource in p.resources.values():
		resource.amount = 20000
	for type: BuildingType.Value in LEVELS:
		p.buildings[type] = Building.new(type, LEVELS[type])
	var map := game.levels[1]
	var base := ActionDigests.first_base(map)
	map.cell_at(base.x, base.y).transition_base.captured_by = "human"
	for y: int in range(p.base_y - 4, p.base_y + 5):
		for x: int in range(p.base_x - 4, p.base_x + 5):
			if x >= 0 and y >= 0 and x < map.width and y < map.height:
				p.add_revealed_cell(1, GridPosition.new(x, y))
	return game


## The 32 actions, each made when its turn comes.
func _steps(game: Game, random: DartRandom) -> Array[Callable]:
	var p := game.human_player()
	var map := game.levels[1]
	var base := ActionDigests.first_base(map)
	var others := game.players.keys().filter(func(id: String) -> bool: return id != "human")
	var up := func(t: BuildingType.Value) -> Callable: return func() -> Action: return UpgradeBuildingAction.new(t)
	var recruit := func(t: UnitType.Value, n: int) -> Callable: return func() -> Action: return RecruitUnitAction.new(t, n)
	var explore := func() -> Action: return ActionDigests.first(game, p, map, func(x: int, y: int) -> Action:
		var pending := p.pending_explorations.any(func(o: ExplorationOrder) -> bool: return o.target.x == x and o.target.y == y)
		return ExploreAction.new(-1 if pending else x, y))
	var collect := func() -> Action: return ActionDigests.first(game, p, map, func(x: int, y: int) -> Action:
		return CollectTreasureAction.new(x, y, 1, random))
	var fight := func() -> Action: return ActionDigests.first(game, p, map, func(x: int, y: int) -> Action:
		var army: Dictionary[UnitType.Value, int] = {}
		for type: UnitType.Value in [UnitType.Value.HARPOONIST, UnitType.Value.GUARDIAN]:
			army[type] = p.units_on_level(1)[type].count
		return FightMonsterAction.new(x, y, 1, army, random))
	var scout: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 1}
	var harpoonist: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 1}
	var steps: Array[Callable] = [
		up.call(BuildingType.Value.HEADQUARTERS), recruit.call(UnitType.Value.SCOUT, 12),
		recruit.call(UnitType.Value.HARPOONIST, 10), up.call(BuildingType.Value.LABORATORY),
		recruit.call(UnitType.Value.GUARDIAN, 3),
	]
	for k: int in 10:
		steps.append(explore)
	steps.append_array([up.call(BuildingType.Value.BARRACKS), collect, collect, fight, fight])
	steps.append_array([
		func() -> Action: return UnlockBranchAction.new(TechBranch.Value.MILITARY),
		func() -> Action: return ResearchTechAction.new(TechBranch.Value.MILITARY),
		func() -> Action: return ResearchTechAction.new(TechBranch.Value.RESOURCES, TechOption.Value.B),
		func() -> Action: return DescendAction.new(base.x, base.y, 1, scout, random),
		func() -> Action: return SendReinforcementsAction.new(base.x, base.y, 1, scout),
		func() -> Action: return SpyBaseAction.new("nobody" if others.is_empty() else str(others[0])),
		func() -> Action: return GarrisonKernelAction.new(harpoonist),
		func() -> Action: return ChooseEventAction.new(true),
		up.call(BuildingType.Value.ALGAE_FARM), up.call(BuildingType.Value.CORAL_CITADEL),
		up.call(BuildingType.Value.VOLCANIC_KERNEL), explore,
	])
	return steps


func test_the_actions_play_as_dart_plays_them_on_new_games() -> void:
	for name: String in GAMES:
		var seed_: int = GAMES[name][0]
		var difficulty: Difficulty.Value = GAMES[name][1]
		var factions: int = GAMES[name][2]
		var game := _game(seed_, difficulty, factions)
		var random := DartRandom.new(seed_)
		var steps := _steps(game, random)
		var expected: Array = ActionHistories.DIGESTS[name]
		assert_eq(steps.size(), expected.size(), name)
		for i: int in steps.size():
			game.turn = 1 + i
			var action: Action = steps[i].call()
			var result := ActionExecutor.new().execute(action, game, game.human_player())
			assert_eq(ActionDigests.digest(game, game.human_player(), action, result), expected[i], "%s %d" % [name, i])
		assert_eq(random.next_int(1000), ActionHistories.NEXT[name], name)
