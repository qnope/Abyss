class_name EventRules
extends RefCounted
## lib/domain/event/event_rules.dart: tuning of the random events drawn every
## few turns. A draw happens at the end of a turn every MIN_GAP to MAX_GAP
## turns; the drawn event waits for the player's choice during the next turn.

## Fewest turns between two draws.
const MIN_GAP := 5
## Most turns between two draws.
const MAX_GAP := 8
## Earliest end of turn of the very first draw of a new game.
const FIRST_DRAW_MIN := 5
## Latest end of turn of the very first draw of a new game.
const FIRST_DRAW_MAX := 8
## Turns a warm or cold current lasts.
const EFFECT_TURNS := 3
## Turns a storm forbids exploring.
const STORM_TURNS := 2
## Turns a wreck stays on the map before sinking out of reach.
const WRECK_TURNS := 5
## Production change of a current: +30 % warm, -30 % cold.
const CURRENT_PERCENT := 30
## Extra noise the base makes every turn of a warm current.
const WARM_NOISE_PER_TURN := 3
## Noise of searching a wreck.
const WRECK_NOISE := 20
## Noise a storm takes off the gauge.
const STORM_NOISE_RELIEF := 10
## No predators may be drawn for a turn before this one.
const PREDATORS_FIRST_TURN := 10
## Strength of a predator wave, in percent of a raid.
const PREDATORS_POWER_PERCENT := 50
## Loot of a predator wave pushed back, in percent of a raid's.
const PREDATORS_LOOT_PERCENT := 50
## Share of the algae given up to bait the predators away.
const BAIT_ALGAE_PERCENT := 30
## Fewest survivors met in the wreckage.
const SURVIVORS_MIN := 3
## Most survivors met in the wreckage.
const SURVIVORS_MAX := 8
## Turns it takes for one more survivor to show up, up to SURVIVORS_MAX.
const SURVIVORS_TURNS_PER_EXTRA := 20
## Units of the most abundant resource handed to the caravan.
const CARAVAN_GIVE := 100
## Units of the scarcest resource the caravan gives back.
const CARAVAN_GET := 70
## Coral found in a wreck.
const WRECK_CORAL := 120
## Ore found in a wreck.
const WRECK_ORE := 80
## Pearls found in a wreck.
const WRECK_PEARLS := 1
## Energy spent each turn of a cold current to heat the farms.
const HEATING_ENERGY_PER_TURN := 20
