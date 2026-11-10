class_name RaidWaveFactory
extends RefCounted
## lib/domain/raid/raid_wave_factory.dart: builds the monster wave of a raid
## from the noise made so far, or from the strength of the base when that is
## the larger.
##
## The wave power is `total_noise × POWER_PER_100_NOISE / 100` (about noise
## ÷ 2.8), or DEFENCE_SHARE_PERCENT % of the DefenceStrength of the base
## when that is more, so a large garrison is never left in peace. Weak waves
## are made of level 1 monsters; stronger ones switch to fewer, tougher
## monsters. The power is shared between two families drawn at random, each
## turned into its own number of monsters.

## Wave power earned by every 100 points of noise, before the difficulty
## scales it (see `Difficulty.monster_percent`).
const POWER_PER_100_NOISE := 36
## Share of the base's strength a wave matches, at least.
const DEFENCE_SHARE_PERCENT := 75
const MIN_MONSTERS := 5
const MEDIUM_FROM_POWER := 30
const HARD_FROM_POWER := 80
const _COST: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 1,
	MonsterDifficulty.Value.MEDIUM: 2,
	MonsterDifficulty.Value.HARD: 4,
}


## `monster_percent` scales the power, so a harder game also switches sooner
## to tougher monsters. `defence_strength` is the DefenceStrength of the
## base the wave strikes. The two families are shuffled with `random`, a die
## of its own when null.
static func from_total_noise(
	total_noise: int, random: DartRandom = null, monster_percent := 100, defence_strength := 0
) -> MonsterLair:
	var size := _size_of(total_noise, monster_percent, defence_strength)
	var level := size.x as MonsterDifficulty.Value
	var families: Array[MonsterFamily.Value] = []
	families.assign(MonsterFamily.available_at(MonsterUnitStats.level_for(level)))
	DartRandom.shuffle(families, random if random != null else DartRandom.unseeded())
	return _wave(level, size.y, families[0], families[1])


## Every wave from_total_noise can draw for the same noise, one for each
## ordered pair of families, so a defence can be checked against all of
## them.
static func every_from_total_noise(total_noise: int, monster_percent := 100) -> Array[MonsterLair]:
	var size := _size_of(total_noise, monster_percent, 0)
	var level := size.x as MonsterDifficulty.Value
	var families := MonsterFamily.available_at(MonsterUnitStats.level_for(level))
	var waves: Array[MonsterLair] = []
	for a: MonsterFamily.Value in families:
		for b: MonsterFamily.Value in families:
			if a != b:
				waves.append(_wave(level, size.y, a, b))
	return waves


## The difficulty of the monsters (x) and their number counted in generic
## ones (y).
static func _size_of(total_noise: int, monster_percent: int, defence_strength: int) -> Vector2i:
	var raw := maxi(total_noise * POWER_PER_100_NOISE, defence_strength * DEFENCE_SHARE_PERCENT)
	var power := DartMath.trunc_div(raw * monster_percent, 10000)
	var level := MonsterDifficulty.Value.EASY
	if power >= HARD_FROM_POWER:
		level = MonsterDifficulty.Value.HARD
	elif power >= MEDIUM_FROM_POWER:
		level = MonsterDifficulty.Value.MEDIUM
	return Vector2i(level, maxi(DartMath.trunc_div(power, _COST[level]), MIN_MONSTERS))


static func _wave(
	level: MonsterDifficulty.Value, generic: int, first: MonsterFamily.Value, second: MonsterFamily.Value
) -> MonsterLair:
	var first_share := DartMath.trunc_div(generic + 1, 2)
	return MonsterLair.new(
		level,
		MonsterUnitStats.count_for(first, first_share),
		first,
		second,
		MonsterUnitStats.count_for(second, generic - first_share),
	)
