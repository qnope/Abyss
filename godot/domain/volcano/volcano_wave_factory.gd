class_name VolcanoWaveFactory
extends RefCounted
## lib/domain/volcano/volcano_wave_factory.dart: builds the kraken wave that
## hits a kernel of a given level: the closer to victory, the more krakens
## rise from the depths.

## Krakens of a wave on a level 0 kernel.
const BASE_KRAKENS := 2
## Krakens added by every three kernel levels. Calibrated so that the
## garrison that wins 9 times in 10 (Briseurs and Gardiens, 2 for 1, with
## the magma rampart) holds about 12 units at level 1, 30 at level 5 and 50
## at level 9.
const KRAKENS_PER_THREE_LEVELS := 4


## Krakens of a wave on a kernel of `kernel_level`, scaled by
## `monster_percent` (see `Difficulty.monster_percent`); at least one. The
## `first_wave` a kernel holder ever faces is gentler: half the krakens,
## rounded up.
static func krakens_for(kernel_level: int, monster_percent := 100, first_wave := false) -> int:
	var per_level := DartMath.trunc_div(KRAKENS_PER_THREE_LEVELS * kernel_level, 3)
	var krakens := maxi(1, DartMath.trunc_div((BASE_KRAKENS + per_level) * monster_percent, 100))
	return DartMath.trunc_div(krakens + 1, 2) if first_wave else krakens


static func from_kernel_level(kernel_level: int, monster_percent := 100, first_wave := false) -> MonsterLair:
	return MonsterLair.new(
		MonsterDifficulty.Value.HARD,
		krakens_for(kernel_level, monster_percent, first_wave),
		MonsterFamily.Value.KRAKEN,
	)
