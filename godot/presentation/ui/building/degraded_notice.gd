class_name DegradedNotice
extends RefCounted
## The detailed [DegradedBadge] of a building that is degraded, or nothing
## (DegradedNotice in lib/presentation/widgets/building/degraded_badge.dart).


## The detailed badge of [param type] within [param buildings], or null when
## it is not degraded.
static func of(
	type: BuildingType.Value, buildings: Dictionary[BuildingType.Value, Building]
) -> DegradedBadge:
	var missing: Variant = BuildingDegradation.missing_headquarters(buildings, type)
	if missing == null:
		return null
	var level: int = missing
	return DegradedBadge.new(level, type, true)
