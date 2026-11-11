class_name TechTarget
extends RefCounted
## Something the player can act on in the research tree: a whole branch (to
## unlock it) or one research level of that branch
## (lib/presentation/widgets/tech/tech_target.dart). Dart's `level` is null
## for the branch; here it is 0, as the levels begin at 1.

var branch: TechBranch.Value
## The research level aimed at, 1 to 5; 0 for the branch itself.
var level: int


func _init(branch_: TechBranch.Value, level_ := 0) -> void:
	branch = branch_
	level = level_


func is_branch() -> bool:
	return level == 0


## A node where the player takes one of two exclusive options (levels 2 and 4).
func is_choice() -> bool:
	return TechTree.is_choice_level(level)


## Whether [param other] aims at the same branch and level.
func equals(other: TechTarget) -> bool:
	return other != null and other.branch == branch and other.level == level
