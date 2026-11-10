class_name ResourceCredit
extends RefCounted
## lib/domain/resource/resource_credit.dart: gains added to a stock of
## resources, each capped by its storage.


## Adds `amounts` to `resources`, each up to its `max_storage`, and returns
## what was actually added by type: 0 for a resource missing from
## `resources`.
static func add(
	resources: Dictionary[ResourceType.Value, GameResource],
	amounts: Dictionary[ResourceType.Value, int],
) -> Dictionary[ResourceType.Value, int]:
	var added: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in amounts:
		var resource: GameResource = resources.get(type)
		if resource == null:
			added[type] = 0
			continue
		var before := resource.amount
		resource.amount = clampi(before + amounts[type], 0, resource.max_storage)
		added[type] = resource.amount - before
	return added
