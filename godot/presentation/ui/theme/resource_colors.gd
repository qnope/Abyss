class_name ResourceColors
## The colour of each resource, in the bars, sheets and lines that show it
## (lib/presentation/extensions/resource_type_extensions.dart: ResourceTypeColor).


## `type.color`.
static func of(type: ResourceType.Value) -> Color:
	match type:
		ResourceType.Value.ALGAE:
			return AbyssColors.ALGAE_GREEN
		ResourceType.Value.CORAL:
			return AbyssColors.CORAL_PINK
		ResourceType.Value.ORE:
			return AbyssColors.ORE_BLUE
		ResourceType.Value.ENERGY:
			return AbyssColors.ENERGY_YELLOW
	return AbyssColors.PEARL_WHITE
