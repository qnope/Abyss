class_name WorksiteRules
extends RefCounted
## lib/domain/worksite/worksite_rules.dart: how many building upgrades and
## research nodes a turn allows.

## Headquarters levels that open one more building site each.
const EXTRA_SITE_AT_HQ: Array[int] = [5, 10]
## Research nodes the laboratory runs each turn.
const RESEARCH_PER_TURN := 1


## Building upgrades allowed each turn with the headquarters at `hq_level`:
## one, plus one per level of EXTRA_SITE_AT_HQ reached.
static func build_sites(hq_level: int) -> int:
	var sites := 1
	for level: int in EXTRA_SITE_AT_HQ:
		if hq_level >= level:
			sites += 1
	return sites


## Headquarters level that opens the next building site (an int), or null
## once every site is open.
static func next_site_at_hq(hq_level: int) -> Variant:
	for level: int in EXTRA_SITE_AT_HQ:
		if hq_level < level:
			return level
	return null
