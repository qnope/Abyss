class_name EmptySaves
extends RefreshingPanel
## What the save list shows when no game is saved: a sonar that detects
## nothing and a way to found a first colony
## (lib/presentation/widgets/save/empty_saves.dart), centred within
## [constant MAX_WIDTH]. The sonar's drawing is a dim glyph here: the
## illustrations of the Flutter version stay out of the Godot one.

## The player wants to found a first colony.
signal new_game_requested

const MAX_WIDTH := 360.0
const ICON_SIZE := 120.0
const GAP := 24

var title_label := Label.new()
var message_label := Label.new()
var new_game_entry := MenuEntry.new("")


func _init() -> void:
	super()
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.custom_minimum_size.x = MAX_WIDTH
	column.add_theme_constant_override(&"separation", GAP)
	var sonar := UiIcon.glyph(&"info", ICON_SIZE, Color(AbyssColors.BIOLUM_CYAN, 0.35))
	title_label.theme_type_variation = &"HeadlineLarge"
	message_label.theme_type_variation = &"BodyMedium"
	message_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	for line: Label in [title_label, message_label]:
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_game_entry.pressed.connect(new_game_requested.emit)
	column.add_child(sonar)
	column.add_child(title_label)
	column.add_child(message_label)
	column.add_child(new_game_entry)
	add_child(column)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"saveEmptyTitle")
	message_label.text = Texts.t(&"saveEmptyMessage")
	new_game_entry.set_label(Texts.t(&"menuNewGame"))
