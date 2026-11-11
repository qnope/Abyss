class_name ResourceChangeLine
extends RefreshingPanel
## One resource of a turn (lib/presentation/widgets/turn/resource_change_line.dart):
## its icon and name, what the base makes ("+5") or makes and spends
## ("+18/-8") in the resource's colour, and "(max atteint)" when the stock
## was full. The confirmation shows what the turn will make, the summary what
## it made: the same line.

const ICON_SIZE := 24.0
const GAP := 8
const PADDING := 4

var type: ResourceType.Value
var produced: int
var consumed: int
var was_capped: bool
var name_label := Label.new()
var amount_label := Label.new()
var capped_label := Label.new()


func _init(type_: ResourceType.Value, produced_: int, consumed_ := 0, was_capped_ := false) -> void:
	type = type_
	produced = produced_
	consumed = consumed_
	was_capped = was_capped_
	super()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label.add_theme_color_override(&"font_color", ResourceColors.of(type))
	capped_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	capped_label.visible = was_capped
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_top", PADDING)
	margin.add_theme_constant_override(&"margin_bottom", PADDING)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(ResourceIcon.new(type, ICON_SIZE))
	for each: Label in [name_label, amount_label, capped_label]:
		row.add_child(each)
	margin.add_child(row)
	add_child(margin)
	refresh()


func refresh() -> void:
	name_label.text = ResourceTexts.display_name(type)
	amount_label.text = "+%d/-%d" % [produced, consumed] if consumed > 0 else "+%d" % produced
	capped_label.text = Texts.t(&"turnStorageFull")
