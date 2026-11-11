class_name FactionScouting
extends RefCounted
## lib/domain/faction/faction_scouting.dart: how deep a faction scouts: more
## scouts below than a player's script, sent ahead of the army, so that its
## fog finds the volcano.

## Explorations a turn on levels 2 and 3.
const DEEP_EXPLORERS := 3


## Scouts an expedition keeps on the deepest level it reaches; the Nomads
## roam with more.
static func deep_scouts_of(personality: FactionPersonality.Value) -> int:
	return 8 if personality == FactionPersonality.Value.CURRENT_NOMADS else 6
