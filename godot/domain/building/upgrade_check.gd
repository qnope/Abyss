class_name UpgradeCheck
extends RefCounted
## lib/domain/building/upgrade_check.dart: whether a building can go up a
## level, and what is missing when it cannot.

var can_upgrade: bool
var is_max_level: bool
var missing_resources: Dictionary[ResourceType.Value, int]
var missing_prerequisites: Dictionary[BuildingType.Value, int]
## The TransitionBaseType.Value to capture first, or null.
var missing_captured_base: Variant
var missing_captured_kernel: bool


func _init(
	can_upgrade_: bool,
	is_max_level_ := false,
	missing_resources_: Dictionary[ResourceType.Value, int] = {},
	missing_prerequisites_: Dictionary[BuildingType.Value, int] = {},
	missing_captured_base_: Variant = null,
	missing_captured_kernel_ := false,
) -> void:
	can_upgrade = can_upgrade_
	is_max_level = is_max_level_
	missing_resources = missing_resources_
	missing_prerequisites = missing_prerequisites_
	missing_captured_base = missing_captured_base_
	missing_captured_kernel = missing_captured_kernel_
