class_name NoiseCostRow
extends HBoxContainer
## "+N bruit": the line shown under an action's cost, so that the player sees
## how much the action fills the raid gauge
## (lib/presentation/widgets/raid/noise_cost_row.dart).

const GAP := 8
const ICON_SIZE := 16.0

var noise: int
var label := Label.new()
var amount_label := Label.new()


func _init(noise_: int) -> void:
	noise = noise_
	add_theme_constant_override(&"separation", GAP)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label.text = "+%d" % noise
	amount_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	add_child(UiIcon.glyph(&"graphic_eq", ICON_SIZE, AbyssColors.WARNING))
	add_child(label)
	add_child(amount_label)
	refresh()


## Writes the label in the language on.
func refresh() -> void:
	label.text = Texts.t(&"raidNoise")


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		refresh()
