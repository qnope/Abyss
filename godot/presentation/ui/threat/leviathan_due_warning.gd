class_name LeviathanDueWarning
extends DueWarning
## The warning on the turn the guardians strike the Faille when the level that
## defends it is empty, or too weak to hold as [LeviathanDefenceAdvisor]
## rehearses it (lib/presentation/widgets/leviathan/leviathan_due_warning.dart).

var defenders: int
var level: int


func _init(defenders_: int, level_: int) -> void:
	defenders = defenders_
	level = level_
	super(&"warning", func() -> String:
		return Texts.t(&"leviathanDueWarning", {"count": defenders_, "level": level_}))
