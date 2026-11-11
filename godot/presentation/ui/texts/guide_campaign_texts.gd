class_name GuideCampaignTexts
extends RefCounted
## lib/presentation/extensions/guide_campaign_texts.dart
## (GuideCampaignText): what the guide says past the tutorial chapter, in the
## player's language: the assaults, the passages, the posts held and the
## kernel.


## The words of a message of the campaign, empty for any other.
static func text(message: GuideMessage) -> String:
	if message is GuideAdmiralNeedsBarracks:
		var needs := message as GuideAdmiralNeedsBarracks
		return Texts.t(&"guideAdmiralNeedsBarracks", {"post": _name(needs.target), "level": needs.barracks_level})
	if message is GuideAdmiralToRecruit:
		return Texts.t(&"guideAdmiralToRecruit", {"post": _name((message as GuideAdmiralToRecruit).target)})
	if message is GuideAdmiralToSend:
		return _to_send(message as GuideAdmiralToSend)
	if message is GuidePostToFind:
		return Texts.t(&"guidePostToFind", {"post": _name((message as GuidePostToFind).target)})
	if message is GuidePostAssault:
		return _assault(message as GuidePostAssault)
	if message is GuideAdmiralFell:
		return Texts.t(&"guideAdmiralFell", {"post": _name((message as GuideAdmiralFell).target)})
	return _situation(message)


## The posts held and the kernel.
static func _situation(message: GuideMessage) -> String:
	if message is GuidePassageNeedsHq:
		var passage := message as GuidePassageNeedsHq
		var building := DartEnum.name_of(BuildingType.Value, passage.passage)
		return Texts.t(&"guidePassageNeedsHq", {"passage": building, "level": passage.headquarters})
	if message is GuidePostUndefended:
		var post := message as GuidePostUndefended
		var type := DartEnum.name_of(TransitionBaseType.Value, post.type)
		return Texts.t(&"guidePostUndefended", {"post": type, "level": post.level})
	if message is GuideKernelWave:
		var wave := message as GuideKernelWave
		if wave.needed == null:
			return Texts.t(&"guideKernelWaveAll", {"monsters": wave.monsters})
		return Texts.t(&"guideKernelWaveNeeded", {"needed": wave.needed})
	if message is GuideLeviathanReturn:
		return _leviathan(message as GuideLeviathanReturn)
	return ""


static func _to_send(send: GuideAdmiralToSend) -> String:
	var passage := TransitionBaseType.Value.FAILLE if send.from == 1 else TransitionBaseType.Value.CHEMINEE
	return Texts.t(&"guideAdmiralToSend", {"post": _name(send.target), "level": send.level, "from": send.from,
		"passage": DartEnum.name_of(TransitionBaseType.Value, passage)})


## The target, then the army to send when one would do.
static func _assault(assault: GuidePostAssault) -> String:
	var intro := Texts.t(&"guidePostAssault", {"post": _name(assault.target)})
	if assault.harpoonists == null:
		return intro
	var planner := AssaultRehearsals.planner()
	var wins := roundi(planner.confidence * planner.rehearsals)
	var army := Texts.t(&"guidePostAssaultArmy",
		{"count": assault.harpoonists, "wins": wins, "rehearsals": planner.rehearsals})
	return "%s %s" % [intro, army]


static func _leviathan(back: GuideLeviathanReturn) -> String:
	var text := Texts.t(&"guideLeviathanReturn", {"level": back.level})
	if back.missing == 0:
		return text
	return "%s %s" % [text, Texts.t(&"guideLeviathanReinforce", {"count": back.missing})]


static func _name(target: AssaultTarget.Value) -> String:
	return DartEnum.name_of(AssaultTarget.Value, target)
