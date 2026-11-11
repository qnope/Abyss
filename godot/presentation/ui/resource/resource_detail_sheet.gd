class_name ResourceDetailSheet
extends BottomSheet
## What a touch on a resource of the bar opens: its icon, name and flavour,
## the stock against its storage and, when the base makes some, the
## production per turn
## (lib/presentation/widgets/resource/resource_detail_sheet.dart).

const ICON_SIZE := 64.0
const GAP := 8
const PAD := 24
const BOTTOM_PAD := 32
const SOURCE_ICON_SIZE := 16.0

var resource: GameResource
var production: int
var name_label := Label.new()
var flavor_label := Label.new()
var stock_label := Label.new()
var production_box := VBoxContainer.new()
var production_title := Label.new()
var source_label := Label.new()
var production_label := Label.new()


## The detail of [param resource_], whose production is
## [param production_] per turn.
func _init(resource_: GameResource, production_: int) -> void:
	resource = resource_
	production = production_
	super()
	var color := ResourceColors.of(resource.type)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var icon := ResourceIcon.new(resource.type, ICON_SIZE)
	name_label.theme_type_variation = &"HeadlineSmall"
	flavor_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	flavor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stock_label.theme_type_variation = &"TitleLarge"
	for label: Label in [name_label, flavor_label, stock_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for label: Label in [name_label, stock_label, production_label]:
		label.add_theme_color_override(&"font_color", color)
	production_title.theme_type_variation = &"TitleSmall"
	production_title.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE)
	source_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	source_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	production_label.theme_type_variation = &"ResourceAmount"
	var source := HBoxContainer.new()
	source.add_theme_constant_override(&"separation", GAP)
	source.add_child(UiIcon.glyph(&"home", SOURCE_ICON_SIZE, AbyssColors.ON_SURFACE_DIM))
	source.add_child(source_label)
	source.add_child(production_label)
	production_box.add_theme_constant_override(&"separation", GAP)
	production_box.add_child(production_title)
	production_box.add_child(source)
	production_box.visible = production > 0
	for node: Control in [icon, name_label, flavor_label, stock_label, production_box]:
		column.add_child(node)
	var padding := MarginContainer.new()
	for side: String in ["left", "right"]:
		padding.add_theme_constant_override("margin_" + side, PAD)
	padding.add_theme_constant_override(&"margin_bottom", BOTTOM_PAD)
	padding.add_child(column)
	body.add_child(padding)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is a resource to show.
	if resource == null:
		return
	name_label.text = ResourceTexts.display_name(resource.type)
	flavor_label.text = ResourceTexts.flavor_text(resource.type)
	stock_label.text = "%d / %d" % [resource.amount, resource.max_storage]
	production_title.text = Texts.t(&"resourceProduction")
	source_label.text = Texts.t(&"resourceMainBuilding")
	production_label.text = "+%d/t" % production
