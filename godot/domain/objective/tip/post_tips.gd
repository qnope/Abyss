class_name PostTips
extends RefCounted
## lib/domain/objective/tip/post_tips.dart: the tips of the posts: the
## admiral who takes them, then holding them, the kernel's garrison, and a
## post lost.


## `postTips`, a const list in Dart: new tips at each call.
static func post_tips() -> Array[Tip]:
	var threats := TipCategory.Value.THREATS
	return [
		Tip.new(TipId.Value.ADMIRAL, TipCategory.Value.MAP, PostTipTriggers.admiral),
		Tip.new(TipId.Value.POST_DEFENCE, threats, PostTipTriggers.post_held),
		Tip.new(TipId.Value.KERNEL_GARRISON, threats, PostTipTriggers.kernel_garrison),
		Tip.new(TipId.Value.POST_LOST, threats, PostTipTriggers.post_lost),
	]
