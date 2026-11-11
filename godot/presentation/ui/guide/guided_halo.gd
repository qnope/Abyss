class_name GuidedHalo
extends GuideHalo
## A [GuideHalo] that follows the guide: it surrounds its content while the
## target of the [GuideScope] is what [member picks] recognizes, and any
## control can carry it (a card, a button, a research node):
##
##     var halo := GuidedHalo.new(button, scope,
##             func(target: GuideTarget) -> bool: return target.end_turn)
##
## A scope of null is a silent guide. The halo reads the scope again when it
## tells [signal GuideScope.changed], and on [method follow] for a halo whose
## answer also depends on something else (the level on show).

var scope: GuideScope
var picks: Callable


func _init(content: Control, scope_: GuideScope, picks_: Callable, corner := 12) -> void:
	super(content, false, corner)
	scope = scope_ if scope_ != null else GuideScope.new()
	picks = picks_
	scope.changed.connect(follow)
	follow()


## Surrounds the content or not, as the guide points now.
func follow() -> void:
	active = scope.points(picks)
