class_name ModelTiers
extends RefCounted
## The tiers of a building model: the nodes Tier1, Tier2 and Tier3, which add
## up (the game shows Tier1, then Tier1 and Tier2, then all three). Review
## tools show a model as it is at a tier by hiding the ones above.

const PREFIX := "Tier"


## The number of a node called Tier<N>, 0 for any other name.
static func number(node_name: String) -> int:
	if not node_name.begins_with(PREFIX):
		return 0
	var digits := node_name.substr(PREFIX.length())
	return int(digits) if digits.is_valid_int() else 0


## The highest tier a model has, 0 when it has none.
static func count(model: Node) -> int:
	var highest := 0
	for node: Node in model.find_children("%s*" % PREFIX, "Node3D", true, false):
		highest = maxi(highest, number(node.name))
	return highest


## Shows the tiers of [param model] up to [param tier] and hides the others.
static func show_up_to(model: Node, tier: int) -> void:
	for node: Node in model.find_children("%s*" % PREFIX, "Node3D", true, false):
		var n := number(node.name)
		if n > 0:
			(node as Node3D).visible = n <= tier
