class_name BuildingCard
extends RefreshingPanel
## A building in a list: its picture, its name in its colour (dimmed while it
## is to build), its level or that it is to build, and a degraded marker if
## the headquarters is too low for it
## (lib/presentation/widgets/building/building_card.dart). A touch tells
## [signal tapped]. A level that rises pops the picture ([IncreasePop]).

## The player touched the card.
signal tapped

const PORTRAIT_SIZE := 48.0
const GAP := 16

var building: Building
## The headquarters level the building is missing, 0 unless it is degraded.
var missing_headquarters: int
var panel := PanelContainer.new()
var tap_button := Button.new()
var name_label := Label.new()
var level_label := Label.new()
var degraded: DegradedBadge
## The picture, which pops when the level rises.
var pop: IncreasePop


func _init(building_: Building, missing_headquarters_ := 0) -> void:
	super()
	building = building_
	missing_headquarters = missing_headquarters_
	var built := building.level > 0
	var color := BuildingColors.of(building.type)
	var title := BuildingTexts.display_name(building.type)
	name_label.theme_type_variation = &"TitleMedium"
	name_label.add_theme_color_override(&"font_color",
		color if built else AbyssColors.dimmed(AbyssColors.ON_SURFACE))
	level_label.theme_type_variation = &"BodySmall"
	level_label.add_theme_color_override(&"font_color",
		AbyssColors.ON_SURFACE_DIM if built else AbyssColors.dimmed(AbyssColors.DISABLED))
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_child(name_label)
	texts.add_child(level_label)
	if missing_headquarters > 0:
		degraded = DegradedBadge.new(missing_headquarters, building.type)
		texts.add_child(degraded)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var picture := PortraitFiles.building(building.type) if built else ""
	var portrait := Portrait.new(title, PORTRAIT_SIZE, color if built else AbyssColors.DISABLED, picture)
	pop = IncreasePop.new(portrait, Vector2.ONE * PORTRAIT_SIZE, AbyssColors.BIOLUM_CYAN, building.level)
	row.add_child(pop)
	row.add_child(texts)
	panel.add_child(row)
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.accessibility_name = title
	tap_button.pressed.connect(tapped.emit)
	add_child(panel)
	add_child(tap_button)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there are labels to write.
	if building == null:
		return
	pop.set_value(building.level)
	name_label.text = BuildingTexts.display_name(building.type)
	level_label.text = Texts.t(&"baseLevel", {"level": building.level}) if building.level > 0 \
		else Texts.t(&"baseNotBuilt")
	tap_button.accessibility_name = name_label.text
