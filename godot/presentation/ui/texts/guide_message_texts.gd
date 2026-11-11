class_name GuideMessageTexts
extends RefCounted
## lib/presentation/extensions/guide_message_extensions.dart: what the guide
## of the tutorial says, in the player's language. A lesson is the guide's
## word on an objective ([GuideLessonTexts]); the other messages are its
## words on a situation, the campaign ones ([GuideCampaignTexts]) and the raid
## alert ([GuideRaidTexts]) in classes of their own.

## `message.text(l10n)`.
static func text(message: GuideMessage) -> String:
	if message is GuideGoalMet:
		return Texts.t(&"guideGoalMet")
	if message is GuideWorksiteTaken:
		return Texts.t(&"guideWorksiteTaken")
	if message is GuideAlreadyRecruited:
		return Texts.t(&"guideAlreadyRecruited")
	if message is GuideExploring:
		return Texts.t(&"guideExploring")
	if message is GuideLesson:
		return GuideLessonTexts.lesson((message as GuideLesson).objective)
	if message is GuideStorm:
		return Texts.t(&"guideStorm", {"turn": (message as GuideStorm).until_turn})
	if message is GuideWreck:
		var wreck := message as GuideWreck
		var key := &"guideWreckWithoutScout" if wreck.has_barracks else &"guideWreckWithoutBarracks"
		return Texts.t(key, {"turn": wreck.until_turn})
	if message is GuideRaidAlert:
		return GuideRaidTexts.text(message as GuideRaidAlert)
	return GuideCampaignTexts.text(message)
