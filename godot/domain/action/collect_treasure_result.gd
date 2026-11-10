class_name CollectTreasureResult
extends ActionResult
## lib/domain/action/collect_treasure_result.dart: what a search added to
## the stocks.

var deltas: Dictionary[ResourceType.Value, int]


## `reason_` null is a success (ActionResult).
func _init(reason_: Variant, deltas_: Dictionary[ResourceType.Value, int] = {}) -> void:
	super(reason_)
	deltas = deltas_


## `CollectTreasureResult.success(deltas)`; its parameter takes a default
## (domain/README.md, "Abstract classes").
static func success(deltas_: Dictionary[ResourceType.Value, int] = {}) -> CollectTreasureResult:
	return CollectTreasureResult.new(null, deltas_)


## `CollectTreasureResult.failure`: empty deltas.
static func failure(reason_: ActionFailure.Value) -> CollectTreasureResult:
	return CollectTreasureResult.new(reason_)
