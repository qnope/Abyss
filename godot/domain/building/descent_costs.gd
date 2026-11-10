class_name DescentCosts
extends RefCounted
## lib/domain/building/descent_costs.dart: what the Descent Module and the
## Pressure Capsule cost. Constants in Dart too: neither map can be changed.

const _DESCENT_MODULE_COST: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.CORAL: 200,
	ResourceType.Value.ORE: 150,
	ResourceType.Value.ENERGY: 80,
	ResourceType.Value.PEARL: 5,
}
const _PRESSURE_CAPSULE_COST: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.CORAL: 400,
	ResourceType.Value.ORE: 300,
	ResourceType.Value.ENERGY: 150,
	ResourceType.Value.PEARL: 15,
}


static func descent_module_cost() -> Dictionary[ResourceType.Value, int]:
	return _DESCENT_MODULE_COST


static func pressure_capsule_cost() -> Dictionary[ResourceType.Value, int]:
	return _PRESSURE_CAPSULE_COST
