class_name TurnResourceChange
extends RefCounted
## lib/domain/turn/turn_result.dart, its type TurnResourceChange: what the
## end of a turn did to one stock. Ported ahead of the `turn` module for the
## TurnEndEntry that holds it.

var type: ResourceType.Value
var produced: int
var consumed: int
var was_capped: bool
var before_amount: int
var after_amount: int


func _init(
	type_: ResourceType.Value,
	produced_: int,
	was_capped_: bool,
	before_amount_: int,
	after_amount_: int,
	consumed_ := 0,
) -> void:
	type = type_
	produced = produced_
	was_capped = was_capped_
	before_amount = before_amount_
	after_amount = after_amount_
	consumed = consumed_
