class_name NoiseRules
extends RefCounted
## lib/domain/raid/noise_rules.dart: tuning of the noise gauge that draws
## raids onto the base.
##
## Every noisy action fills the gauge; once it reaches THRESHOLD a raid is
## announced WARNING_TURNS turns ahead and the gauge empties.

## Gauge level that triggers a raid announcement.
const THRESHOLD := 40
## Noise the base makes every turn, whatever the player does.
const PER_TURN := 3
## Noise per recruited unit.
const PER_RECRUIT := 1
## Noise of launching an exploration.
const PER_EXPLORATION := 1
## Noise of any fight (lair, transition base, volcanic kernel).
const PER_FIGHT := 3
## Turns between the announcement and the raid.
const WARNING_TURNS := 2
## No raid may hit the base before the end of this turn.
const FIRST_RAID_TURN := 10
## Each level of the volcanic kernel makes this many times the noise of
## another building. Back to 1 since the kraken waves keep the end of the
## game busy on their own.
const KERNEL_UPGRADE_FACTOR := 1


## Noise of upgrading a building of `type` to `reached_level`.
static func for_upgrade(type: BuildingType.Value, reached_level: int) -> int:
	if type == BuildingType.Value.VOLCANIC_KERNEL:
		return reached_level * KERNEL_UPGRADE_FACTOR
	return reached_level
