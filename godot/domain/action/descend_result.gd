class_name DescendResult
extends ActionResult
## lib/domain/action/descend_result.dart: the level a descent reached and
## the units it sent; both null on a failure.

## An int, or null on a failure.
var target_level: Variant
## The units sent; empty on a failure, where Dart holds null.
var units_sent: Dictionary[UnitType.Value, int]


## `reason_` null is a success (ActionResult).
func _init(reason_: Variant, target_level_: Variant = null, units_sent_: Dictionary[UnitType.Value, int] = {}) -> void:
	super(reason_)
	target_level = target_level_
	units_sent = units_sent_


## `DescendResult.success`; its parameters take a default (domain/README.md,
## "Abstract classes").
static func success(target_level_ := 0, units_sent_: Dictionary[UnitType.Value, int] = {}) -> DescendResult:
	return DescendResult.new(null, target_level_, units_sent_)


## `DescendResult.failure`: no level, no units.
static func failure(reason_: ActionFailure.Value) -> DescendResult:
	return DescendResult.new(reason_)
