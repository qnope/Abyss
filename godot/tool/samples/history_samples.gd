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


## An assault on the base of "Nacre", seen from either side; without the
## post, the kernel and the losses the Dart helper may also take.
static func base_assault_entry(victory: bool, defending: bool) -> BaseAssaultEntry:
	return BaseAssaultEntry.new(
		14, victory, defending, "Nacre", fight(victory), {}, {}, {}, {}, 2, 0, 5, 5, {}, {}
	)


## The lair of level 2 of the Dart helper.
static func _lair() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 3)
