class_name GuideRaidTexts
extends RefCounted
## lib/presentation/extensions/guide_message_extensions.dart
## (GuideRaidAlert._text): the raid announced, then how to push it back.


## The raid, then the advice.
static func text(alert: GuideRaidAlert) -> String:
	var intro := Texts.t(&"guideRaidIntro", {"turn": alert.arrival_turn, "monsters": alert.monsters})
	return "%s %s" % [intro, _advice(alert)]


static func _advice(alert: GuideRaidAlert) -> String:
	if alert.needed == null:
		return Texts.t(&"guideRaidOutOfReach")
	if alert.missing <= 0:
		return Texts.t(&"guideRaidHeld")
	var then: String
	if alert.can_recruit:
		then = Texts.t(&"guideRaidRecruitNow", {"missing": alert.missing})
	elif alert.last_turn:
		then = Texts.t(&"guideRaidHoldOn")
	else:
		then = Texts.t(&"guideRaidRecruitNextTurn", {"missing": alert.missing})
	return "%s %s" % [Texts.t(&"guideRaidNeeded", {"needed": alert.needed, "missing": alert.missing}), then]
