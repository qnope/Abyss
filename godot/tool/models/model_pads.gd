extends RefCounted
## Seats the buildings rendered with the island on their pads, as the game
## will: a model whose root node is named as one of the island's pads
## (Headquarters, Pads/Headquarters) stands at that pad's origin.


## Moves each model under [param group] whose root node names a pad of
## another model there (the island's Pads/<Name>) onto that pad.
static func seat(group: Node3D) -> void:
	var pads: Dictionary[StringName, Vector3] = {}
	for model: Node in group.get_children():
		var holder := model.get_node_or_null("Pads")
		if holder != null:
			for pad: Node in holder.get_children():
				pads[pad.name] = (pad as Node3D).transform.origin
	for model: Node in group.get_children():
		for root: Node in model.get_children():
			if pads.has(root.name):
				(model as Node3D).position = pads[root.name]
