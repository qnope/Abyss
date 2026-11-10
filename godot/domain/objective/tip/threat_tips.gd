class_name ThreatTips
extends RefCounted
## lib/domain/objective/tip/threat_tips.dart: the tips of the threats: the
## raids on the base, the monster families, the waves of the Volcano and the
## attacks of the factions.


## `threatTips`, a const list in Dart: new tips at each call.
static func threat_tips() -> Array[Tip]:
	var threats := TipCategory.Value.THREATS
	return [
		Tip.new(TipId.Value.RAID_ANNOUNCED, threats, TipTriggers.raid_announced),
		Tip.new(TipId.Value.RAID_REPORT, threats, TipTriggers.raid_fought),
		Tip.new(TipId.Value.LAST_CHANCE, threats, TipTriggers.last_chance),
		Tip.new(TipId.Value.MONSTER_FAMILIES, threats, TipTriggers.monster_family),
		Tip.new(TipId.Value.VOLCANO_WAVE, threats, TipTriggers.volcano_wave),
		Tip.new(TipId.Value.FACTION_ATTACK, threats, TipTriggers.faction_attack),
	]
