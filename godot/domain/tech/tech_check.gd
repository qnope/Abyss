class_name TechCheck
extends RefCounted
## lib/domain/tech/tech_check.dart: whether a branch can be unlocked or a
## node researched, and what is missing when it cannot.

var can_act: bool
var is_max_level: bool
var missing_resources: Dictionary[ResourceType.Value, int]
var required_lab_level: int
var current_lab_level: int
var branch_locked: bool
var previous_node_missing: bool


func _init(
	can_act_: bool,
	is_max_level_ := false,
	missing_resources_: Dictionary[ResourceType.Value, int] = {},
	required_lab_level_ := 0,
	current_lab_level_ := 0,
	branch_locked_ := false,
	previous_node_missing_ := false,
) -> void:
	can_act = can_act_
	is_max_level = is_max_level_
	missing_resources = missing_resources_
	required_lab_level = required_lab_level_
	current_lab_level = current_lab_level_
	branch_locked = branch_locked_
	previous_node_missing = previous_node_missing_
