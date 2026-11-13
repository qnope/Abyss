class_name StoryCase
extends TestCase
## The base of the tests of the turn story: a game against two factions whose
## base, Faille and volcano the sieges are told on, and the turn results that
## carry what the story reads.

const Harpoonist := UnitType.Value.HARPOONIST
const VOLCANO := KernelGarrison.VOLCANO_LEVEL

var game: Game
var human: Player


func before_each() -> void:
	game = GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	human = game.human_player()


## The cell of [param level] holding [param content], the last in the grid.
func find(level: int, content: CellContentType.Value) -> Vector2i:
	var map: GameMap = game.levels[level]
	var found := Vector2i.ZERO
	for y in map.height:
		for x in map.width:
			if map.cell_at(x, y).content == content:
				found = Vector2i(x, y)
	return found


## A cell of the first level the player has not seen, the [param nth] of them.
func hidden(nth := 0) -> Vector2i:
	var seen := human.revealed_cells_set_on_level(1)
	var found: Array[Vector2i] = []
	for y in game.levels[1].height:
		for x in game.levels[1].width:
			if not seen.has(Vector2i(x, y)):
				found.append(Vector2i(x, y))
	return found[nth]


func see(level: int, at: Vector2i) -> void:
	human.add_revealed_cell(level, GridPosition.new(at.x, at.y))


## A fight of two rounds, (10, 5) then (7, 3) by the side that fights as the
## player, whose army entered as [param army] (units by type).
func fight(army: Dictionary[UnitType.Value, int] = {}) -> FightResult:
	var summaries: Array[FightTurnSummary] = [
		FightTurnSummary.new(1, 2, 0, 10, 5, 3, 2, 12, 8),
		FightTurnSummary.new(2, 2, 1, 7, 3, 3, 0, 9, 0),
	]
	return FightResult.new(CombatSide.Value.PLAYER, 2, summaries,
		CombatantBuilder.player_combatants_from(army), [] as Array[Combatant], 4, 0)


func lair(family: Variant = MonsterFamily.Value.HUNTER) -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 4, family)


func raid(victory := true) -> RaidReport:
	return RaidReport.new(4, victory, lair(), fight(), 1, {}, {}, {}, {}, {}, {})


func wave(victory := true) -> VolcanoReport:
	return VolcanoReport.new(4, victory, lair(MonsterFamily.Value.KRAKEN), fight(), 1, {}, {}, {}, {})


## An attack of the faction [param personality] (null: the guardians), won by the
## attacker or not, on the base, or the post of code [param post], or the volcano.
func attack(won: bool, personality: Variant = FactionPersonality.Value.ANGLER_CULT, post: Variant = null) -> FactionAttackReport:
	var army: Dictionary[UnitType.Value, int] = {}
	if personality != null:
		army[Harpoonist] = 3
	var entry := BaseAssaultEntry.new(4, won, true, "Nacre", fight(army), {}, {}, {}, {}, 2, 0, 5, 5, {}, {}, post)
	return FactionAttackReport.new("nacre", "Nacre", personality, entry)


func result(raid_: RaidReport = null, predators: RaidReport = null, volcano: VolcanoReport = null,
		attacks: Array[FactionAttackReport] = []) -> TurnResult:
	return TurnResult.new([], 3, 4, false, [], {}, [], [], raid_, null, null, volcano, null, null, null,
		predators, [], [], attacks)
