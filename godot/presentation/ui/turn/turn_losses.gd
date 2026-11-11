class_name TurnLosses
extends RefCounted
## The two loss sections of a turn, told before it ends (the confirmation) and
## after (the summary): DeactivatedBuildingsSection and LostUnitsSection of
## lib/presentation/widgets/turn/turn_loss_sections.dart. They are built here
## and not by static functions of [LossSection] itself: a node class that
## builds itself in a static function leaks its script when it extends another
## script of the project (Godot 4.7).


## The buildings shut down for lack of energy, one line each.
static func deactivated(buildings: Array[BuildingType.Value]) -> LossSection:
	return LossSection.new(&"warning", AbyssColors.WARNING, &"turnBuildingsDeactivated",
		func() -> PackedStringArray:
			var names := PackedStringArray()
			for type in buildings:
				names.append(BuildingTexts.display_name(type))
			return names)


## The units lost for lack of algae, with how many of each.
static func lost_units(units: Dictionary[UnitType.Value, int]) -> LossSection:
	return LossSection.new(&"error", AbyssColors.ERROR, &"turnUnitsLost",
		func() -> PackedStringArray:
			var lines := PackedStringArray()
			for type in units:
				lines.append("%s: -%d" % [UnitTexts.display_name(type), units[type]])
			return lines)
