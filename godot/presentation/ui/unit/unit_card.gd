class_name UnitCard
extends RefreshingPanel
## A unit in a list: its picture, its name in its colour (dimmed while it is
## locked) and, under it, how many serve (at each place when it serves in
## several: "Niv. 1: 5 · Niv. 2: 3") or that it is locked
## (lib/presentation/widgets/unit/unit_card.dart). A touch tells [signal
## tapped]. The pop and the floating gain of its count are not ported: the
## parade shows a recruit arriving.

## The player touched the card.
signal tapped

const PORTRAIT_SIZE := 40.0
const GAP := 16
const LOCK_SIZE := 14.0

var type: UnitType.Value
## The units of the type at each place, the empty ones included.
var counts_per_level: Dictionary[int, int]
var unlocked: bool
var panel := PanelContainer.new()
var tap_button := Button.new()
var name_label := Label.new()
var detail_label := Label.new()
var lock_icon: UiIcon


func _init(type_: UnitType.Value, counts_per_level_: Dictionary[int, int], unlocked_: bool) -> void:
	super()
	type = type_
	counts_per_level = counts_per_level_
	unlocked = unlocked_
	name_label.theme_type_variation = &"TitleMedium"
	name_label.add_theme_color_override(&"font_color",
		UnitColors.of(type) if unlocked else AbyssColors.dimmed(AbyssColors.ON_SURFACE))
	detail_label.theme_type_variation = &"BodySmall"
	detail_label.add_theme_color_override(&"font_color",
		AbyssColors.ON_SURFACE_DIM if unlocked else AbyssColors.dimmed(AbyssColors.DISABLED))
	var detail := HBoxContainer.new()
	if not unlocked:
		lock_icon = UiIcon.glyph(&"lock", LOCK_SIZE, AbyssColors.dimmed(AbyssColors.DISABLED))
		detail.add_child(lock_icon)
	detail.add_child(detail_label)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_child(name_label)
	texts.add_child(detail)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UnitPortrait.of(type, PORTRAIT_SIZE, not unlocked, not unlocked))
	row.add_child(texts)
	panel.add_child(row)
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.pressed.connect(tapped.emit)
	add_child(panel)
	add_child(tap_button)
	refresh()


func refresh() -> void:
	name_label.text = UnitTexts.display_name(type)
	tap_button.accessibility_name = name_label.text
	detail_label.text = _detail() if unlocked else Texts.t(&"unitLocked")


## "7 unités", or the count at each place when there are several.
func _detail() -> String:
	var held := PackedStringArray()
	var total := 0
	for place: int in counts_per_level:
		total += counts_per_level[place]
		if counts_per_level[place] > 0:
			held.append("%s: %d" % [_place_of(place), counts_per_level[place]])
	if held.size() <= 1:
		return Texts.t(&"unitTotalCount", {"count": total})
	return " · ".join(held)


static func _place_of(place: int) -> String:
	if place == KernelGarrison.STOCK_KEY:
		return Texts.t(&"unitPlaceKernel")
	return Texts.t(&"baseLevelShort", {"level": place})
