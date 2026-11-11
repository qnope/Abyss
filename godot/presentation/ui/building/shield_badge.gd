class_name ShieldBadge
extends RefreshingPanel
## "Rempart de la base : 120 PV, DEF 7": the rampart the Coral Citadel raises
## (lib/presentation/widgets/building/base_shield_badge.dart). Hidden while the
## citadel is not built (level 0). It reads the buildings it is given as they
## change, and redraws on [method refresh].

var buildings: Dictionary[BuildingType.Value, Building]
var badge: InfoBadge


func _init(buildings_: Dictionary[BuildingType.Value, Building]) -> void:
	super()
	buildings = buildings_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge = InfoBadge.new(UiIcon.glyph_path(&"shield"), AbyssColors.CORAL_PINK, "")
	add_child(badge)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is a badge to write.
	if badge == null:
		return
	var level := Building.level_in(buildings, BuildingType.Value.CORAL_CITADEL)
	visible = level > 0
	badge.show_text(Texts.t(&"baseShield", {"rampart": RampartTexts.coral(level)}), AbyssColors.CORAL_PINK)
