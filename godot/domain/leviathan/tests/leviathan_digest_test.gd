extends TestCase
## Not in the Dart files: the guardians coming back on the games of
## GameFactory, as the Dart rules play them, read by a scratch script run
## with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, factionCount: 2, humanId: 'human', difficulty: normal,
## hard, easy for the seeds 3, 11, 24), the tutorial over; the first
## Faille of level 1, captured by the human afresh (a new LeviathanReturn)
## in each scene but T. T: the assaults of `_assaults`, the dice
## Random(seed + 1 to 4), the ends of turn SeededRandom(seed * 40 + t). A:
## turn 12, the Module at 2, the advice for three armies
## on level 2, then 3 + seed % 4 Harpoonists, 2 Guardians and a Scout, five
## ends of turn with SeededRandom(seed * 10 + t). B: turn 30, no Module
## until the fourth end of turn, 10 + seed % 5 Harpoonists, 8 Guardians and
## 2 Briseurs, eight ends of turn, SeededRandom(seed * 20 + t). C: turn 50,
## the Module at 2, 7 Harpoonists and 4 Guardians, four ends of turn,
## SeededRandom(seed * 30 + t). Compared with LeviathanHistories.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT
const MODULE := BuildingType.Value.DESCENT_MODULE
const DIFFICULTIES: Dictionary[int, Difficulty.Value] = {
	3: Difficulty.Value.NORMAL, 11: Difficulty.Value.HARD, 24: Difficulty.Value.EASY,
}

var _game: Game
var _post: TransitionBase
var _at: GridPosition


func _capture(module_level: int) -> void:
	var human := _game.human_player()
	_post.captured_by = human.id
	human.buildings[MODULE] = Building.new(MODULE, module_level)
	_game.leviathan_return = LeviathanReturn.new()
	LeviathanResolver.on_capture(_game, human, _post, 1, _at)


func _steps(count: int, dice: int, lines: Array[String], module_at := -1) -> void:
	for t: int in count:
		if t == module_at:
			_game.human_player().buildings[MODULE].level = 1
		lines.append(LeviathanDigests.step(_game, _post, dice + t))


## T: the human's assaults on turn 9 (and 10 for the last), through
## ActionExecutor: the Faille without an admiral, refused; the first
## Cheminée of level 2, taken; the Faille with too few, lost; the Faille,
## taken, which schedules the return; then seven ends of turn, the Module
## built before the third.
func _assaults(seed_: int, lines: Array[String]) -> void:
	var faille := TransitionBaseType.Value.FAILLE
	_game.turn = 9
	lines.append(LeviathanDigests.assault(_game, faille, 1, {HARPOONIST: 5}, seed_ + 1))
	lines.append(LeviathanDigests.assault(_game, TransitionBaseType.Value.CHEMINEE, 2, {
		UnitType.Value.ABYSS_ADMIRAL: 1, GUARDIAN: 60, UnitType.Value.DOME_BREAKER: 50 + seed_ % 7,
	}, seed_ + 2))
	lines.append(LeviathanDigests.assault(_game, faille, 1, {
		UnitType.Value.ABYSS_ADMIRAL: 1, HARPOONIST: 4 + seed_ % 3, GUARDIAN: 1,
	}, seed_ + 3))
	_game.turn = 10
	lines.append(LeviathanDigests.assault(_game, faille, 1, {
		UnitType.Value.ABYSS_ADMIRAL: 1, HARPOONIST: 25 + seed_ % 6, GUARDIAN: 12, SCOUT: 2,
	}, seed_ + 4))
	WarDigests.put(_game.human_player(), 2, {HARPOONIST: 9, GUARDIAN: 5})
	_steps(7, seed_ * 40, lines, 2)


func _scene(seed_: int) -> Array[String]:
	var lines: Array[String] = []
	var human := _game.human_player()
	var map: GameMap = _game.levels[1]
	_at = WarDigests.first(map, func(x: int, y: int) -> bool:
		var base := map.cell_at(x, y).transition_base
		return base != null and base.type == TransitionBaseType.Value.FAILLE)
	_post = map.cell_at(_at.x, _at.y).transition_base
	_assaults(seed_, lines)
	_game.turn = 12
	var weak: Dictionary[UnitType.Value, int] = {HARPOONIST: 3 + seed_ % 4, GUARDIAN: 2, SCOUT: 1}
	_capture(2)
	var none: Dictionary[UnitType.Value, int] = {}
	var few: Dictionary[UnitType.Value, int] = {HARPOONIST: 3}
	var mixed: Dictionary[UnitType.Value, int] = {GUARDIAN: 6, SCOUT: 2}
	for army: Dictionary[UnitType.Value, int] in [none, few, mixed]:
		WarDigests.put(human, 2, army)
		var needed: Variant = LeviathanDefenceAdvisor.units_for(_game, human, 2)
		lines.append("advice %s %s" % [LeviathanDigests.counts(army), WarDigests.text(needed)])
	WarDigests.put(human, 2, weak)
	_steps(5, seed_ * 10, lines)
	_game.turn = 30
	var strong: Dictionary[UnitType.Value, int] = {HARPOONIST: 10 + seed_ % 5, GUARDIAN: 8, UnitType.Value.DOME_BREAKER: 2}
	WarDigests.put(human, 2, strong)
	_capture(0)
	_steps(8, seed_ * 20, lines, 3)
	_game.turn = 50
	var middling: Dictionary[UnitType.Value, int] = {HARPOONIST: 7, GUARDIAN: 4}
	WarDigests.put(human, 2, middling)
	_capture(2)
	_steps(4, seed_ * 30, lines)
	return lines


func test_the_leviathan_returns_as_dart_plays_it() -> void:
	for seed_: int in [3, 11, 24]:
		_game = GameFactory.new_game("Nemo", seed_, DIFFICULTIES[seed_], false, 2, null, "human")
		ObjectiveMigration.state_of(_game, _game.human_player()).tutorial_enabled = false
		var lines := _scene(seed_)
		var expected: Array = LeviathanHistories.DIGESTS[str(seed_)]
		assert_eq(lines.size(), expected.size(), str(seed_))
		for i: int in lines.size():
			assert_eq(lines[i], expected[i], "%d: %d" % [seed_, i])
