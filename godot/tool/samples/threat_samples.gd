class_name ThreatSamples
extends RefCounted
## The raids and the kraken waves the tests of the threat reports show: real
## fights of the domain, won by a big army or lost with none, on dice seeded
## so that they come out the same each time.

const TURN := 12


## A wave of two families, as the raids draw them.
static func wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 12, MonsterFamily.Value.SWARM, MonsterFamily.Value.ARMOURED, 4)


## A raid at turn 12 on a base with a Coral Citadel at [param rampart], won by
## 300 Harpoonists or lost with nobody to defend.
static func raid_report(victory: bool, rampart := 0, surprise := false) -> RaidReport:
	var army: Dictionary[UnitType.Value, int] = {}
	if victory:
		army = {UnitType.Value.HARPOONIST: 300, UnitType.Value.GUARDIAN: 100}
	var player := RaidSamples.raid_player(army, rampart, 1)
	return RaidBattle.fight(player, wave(), TURN, DartRandom.new(1), 100, surprise)


## A kraken wave at turn 12 on a kernel of [param kernel_level], won by a
## garrison of 300 Harpoonists or lost with an empty one.
static func volcano_report(victory: bool, kernel_level := 3) -> VolcanoReport:
	var garrison: Dictionary[UnitType.Value, int] = {}
	if victory:
		garrison = {UnitType.Value.HARPOONIST: 300}
	var player := RaidSamples.volcano_player(kernel_level, garrison)
	return VolcanoBattle.fight(player, VolcanoWaveFactory.from_kernel_level(kernel_level), TURN, DartRandom.new(1))


## A turn 12 -> 13 whose result holds the given reports and announcements.
static func result(
	raid: RaidReport = null, announced_raid: MonsterLair = null, volcano: VolcanoReport = null,
	announced_wave: MonsterLair = null, predators: RaidReport = null
) -> TurnResult:
	return TurnResult.new([], TURN, TURN + 1, false, [], {}, [], [], raid, announced_raid,
		TURN + 2 if announced_raid != null else null, volcano, announced_wave, null, null, predators)
