class_name BaseTips
extends RefCounted
## lib/domain/objective/tip/base_tips.dart: the tips of the base: the noise,
## the building sites, the research choices.


## `baseTips`, a const list in Dart: new tips at each call.
static func base_tips() -> Array[Tip]:
	var base := TipCategory.Value.BASE
	return [
		Tip.new(TipId.Value.NOISE_GAUGE, base, TipTriggers.noise),
		Tip.new(TipId.Value.WORKSITES, base, TipTriggers.worksites),
		Tip.new(TipId.Value.TECH_CHOICE, base, TipTriggers.tech_choice),
	]
