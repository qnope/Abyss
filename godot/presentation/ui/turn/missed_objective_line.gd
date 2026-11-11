class_name MissedObjectiveLine
extends RefreshingPanel
## A temporary objective that ended unmet, in the summary of the turn
## (lib/.../objective_turn_section.dart, `_missed`): its title struck through,
## then "(raté)", beside the hourglass, in the warning colour. The title is
## written again when the language changes.

const ICON_SIZE := 20.0
const GAP := 8
const PADDING := 2

var objective: TemporaryObjective
var label := RichTextLabel.new()


func _init(objective_: TemporaryObjective) -> void:
	objective = objective_
	super()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override(&"default_color", AbyssColors.WARNING)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_top", PADDING)
	margin.add_theme_constant_override(&"margin_bottom", PADDING)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UiIcon.glyph(&"hourglass_disabled", ICON_SIZE, AbyssColors.WARNING))
	row.add_child(label)
	margin.add_child(row)
	add_child(margin)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is an objective to write.
	if objective == null:
		return
	var title := TemporaryObjectiveTexts.display_title(objective).replace("[", "[lb]")
	label.text = "[s]%s[/s] %s" % [title, Texts.t(&"objectiveMissed")]
