class_name ObjectiveBanner
extends RefreshingPanel
## The thin strip under the status bars (lib/.../objective_banner.dart): the
## objective the player is on, its chapter and its progress, and the temporary
## objectives of the events. Hidden once every objective is completed. A touch
## opens the [ObjectivesSheet] on the modals.

const PADDING := Vector2i(12, 3)
const GAP := 8
const FLAG_SIZE := 16.0
const ART_SIZE := 20.0
const CHEVRON_SIZE := 16.0

var actions: GameActions
var chapter_label := Label.new()
var progress_label := Label.new()
var temporary_label := Label.new()
## The flag, or the post the objective asks to take.
var lead := Control.new()
## The touch area over the strip.
var tap_button := Button.new()
var _modals: ModalLayer


func _init(actions_: GameActions, modals: ModalLayer) -> void:
	actions = actions_
	_modals = modals
	super()
	add_theme_stylebox_override(&"panel", AbyssBox.flat(AbyssColors.SURFACE_DIM, 0, PADDING))
	for label: Label in [chapter_label, progress_label, temporary_label]:
		label.theme_type_variation = &"BodySmall"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chapter_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	temporary_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_label.clip_text = true
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for part: Control in [lead, chapter_label, progress_label, temporary_label,
			UiIcon.glyph(&"chevron_right", CHEVRON_SIZE, AbyssColors.ON_SURFACE_DIM)]:
		row.add_child(part)
	var strip := PanelContainer.new()
	strip.theme_type_variation = AbyssSurfaceTheme.BARE
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.pressed.connect(_open_sheet)
	strip.add_child(row)
	strip.add_child(tap_button)
	add_child(strip)
	refresh()


func refresh() -> void:
	var game := actions.game
	var player := game.human_player()
	var objective := CurrentObjective.of(game, player)
	visible = objective != null
	if objective == null:
		return
	var progress := objective.progress_of(game, player)
	var color := AbyssColors.SUCCESS if progress.is_done() else AbyssColors.BIOLUM_CYAN
	_show_lead(objective, color)
	chapter_label.text = ChapterTexts.title(objective.chapter)
	progress_label.text = Texts.t(&"objectiveProgress", {"title": ObjectiveTexts.display_title(objective),
		"current": progress.current, "target": progress.target})
	progress_label.add_theme_color_override(&"font_color", color)
	var temporary := TemporaryObjectives.active_of(game, player)
	temporary_label.visible = not temporary.is_empty()
	var names := PackedStringArray()
	for each in temporary:
		names.append(TemporaryObjectiveTexts.short_label(each.kind))
	temporary_label.text = "+ " + ", ".join(names)
	tap_button.accessibility_name = progress_label.text


## The flag, or the picture of the post an objective asks to take.
func _show_lead(objective: Objective, color: Color) -> void:
	for old in lead.get_children():
		lead.remove_child(old)
		old.free()
	var post: Variant = ObjectivePosts.type_of(objective.id)
	var picture: Control
	if post == null:
		picture = UiIcon.glyph(&"flag", FLAG_SIZE, color)
	else:
		var type: TransitionBaseType.Value = post
		picture = PostPicture.of(type, PostHolder.Value.GUARDIANS, ART_SIZE)
	lead.custom_minimum_size = picture.custom_minimum_size
	lead.add_child(picture)


func _open_sheet() -> void:
	_modals.open(ObjectivesSheet.new(actions.game))
