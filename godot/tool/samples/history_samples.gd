class_name HistorySamples
extends RefCounted
## The history entries of the fights the Dart tests take from
## test/helpers/history_entry_samples.dart, and the fight of two turns of
## `buildTestFight` (test/helpers/transition_fight_fixtures.dart) they hold.


## `buildTestFight`: a fight of two turns, won or lost by the player.
static func fight(player_wins: bool, initial_monsters := 4, final_monsters := 0) -> FightResult:
	var summaries: Array[FightTurnSummary] = [
		FightTurnSummary.new(1, 2, 0, 10, 5, 3, 2, 12, 8),
		FightTurnSummary.new(2, 2, 1, 7, 3, 3, 0, 9, 0),
	]
	return FightResult.new(
		CombatSide.Value.PLAYER if player_wins else CombatSide.Value.MONSTER,
		2,
		summaries,
		[],
		[],
		initial_monsters,
		final_monsters,
	)


## The capture, won in two fight turns, of the base named `name`.
static func capture_entry(name: String) -> CaptureEntry:
	return CaptureEntry.new(6, name, fight(true))


## A raid on the base, or a school of predators when `surprise`.
static func raid_entry(victory: bool, surprise := false) -> RaidEntry:
	return RaidEntry.new(11, victory, _lair(), fight(victory), {}, {}, {}, {}, {}, {}, 0, surprise)


## A kraken wave on the volcanic kernel.
static func volcano_entry(victory: bool) -> VolcanoEntry:
	return VolcanoEntry.new(20, victory, _lair(), fight(victory), 2, {}, {}, {}, {})


## An assault of "Nacre", seen from either side: on the base, or on the
## post of code `post` (a String); `kernel`, the record `(before, after)` of
## the Dart helper, is a Vector2i of the levels of the rampart, or null for
## 2 then 0.
static func base_assault_entry(
	victory: bool,
	defending: bool,
	post: Variant = null,
	kernel: Variant = null,
	lost_with_post: Dictionary[UnitType.Value, int] = {},
	dead: Dictionary[UnitType.Value, int] = {},
	passage_destroyed := true,
) -> BaseAssaultEntry:
	var rampart: Vector2i = Vector2i(2, 0) if kernel == null else kernel
	return BaseAssaultEntry.new(
		14, victory, defending, "Nacre", fight(victory), {}, {}, {}, dead, rampart.x, rampart.y,
		5, 5, {}, {}, post, lost_with_post, passage_destroyed,
	)


## The lair of level 2 of the Dart helper.
static func _lair() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 3)


## `fightOf` of test/domain/game/game_statistics_helper.dart: a fight of one
## turn won by `winner` against `monsters` monsters.
static func statistics_fight(winner: CombatSide.Value, monsters: int) -> FightResult:
	return FightResult.new(winner, 1, [], [], [], monsters, 0)


## `combatOf`: a combat against an easy lair of 3, won or lost.
static func statistics_combat(victory: bool, monsters: int) -> CombatEntry:
	var winner := CombatSide.Value.PLAYER if victory else CombatSide.Value.MONSTER
	return CombatEntry.new(
		1, victory, 0, 0, MonsterLair.new(MonsterDifficulty.Value.EASY, 3),
		statistics_fight(winner, monsters), {}, {}, {}, {}, {},
	)


## `gameWith`: the game during `turn` of player "p1" named "Test", based at
## (0, 0), holding `history`.
static func statistics_game(turn := 1, history: Array[HistoryEntry] = []) -> Game:
	var player := Player.new("Test", "p1", 0, 0, null, null, null, null, [], [], {}, history)
	return Game.new(player.id, {player.id: player}, turn)
