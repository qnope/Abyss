class_name VolcanicKernelCosts
extends RefCounted
## lib/domain/building/volcanic_kernel_costs.dart: what each level of the
## volcanic kernel costs.


static func volcanic_kernel_cost(current_level: int) -> Dictionary[ResourceType.Value, int]:
	var scale := current_level * current_level + 1
	return {
		ResourceType.Value.CORAL: 50 * scale,
		ResourceType.Value.ORE: 40 * scale,
		ResourceType.Value.ENERGY: 12 * scale,
		ResourceType.Value.PEARL: 5 + 3 * (current_level + 1),
	}
