class_name UndefendedPostWarning
extends RefreshingPanel
## The warning before the end of a turn: one line per post the player holds
## with nobody on the level below to defend it
## (lib/presentation/widgets/turn/undefended_post_warning.dart). It never
## blocks the turn. Flutter draws each post's picture; here a warning glyph,
## the post being a thing of the map (lot 9) and its picture of step 7.

const ICON_SIZE := 24.0
const GAP := 8

var posts: Array[TransitionBase]
var labels: Array[Label] = []


func _init(posts_: Array[TransitionBase]) -> void:
	posts = posts_
	super()
	var column := VBoxContainer.new()
	column.add_child(HSeparator.new())
	for each in posts:
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
		labels.append(label)
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", GAP)
		row.add_child(UiIcon.glyph(&"warning", ICON_SIZE, AbyssColors.WARNING))
		row.add_child(label)
		column.add_child(row)
	add_child(column)
	refresh()


func refresh() -> void:
	for i in labels.size():
		labels[i].text = Texts.t(&"undefendedPostWarning", {
			"kind": DartEnum.name_of(TransitionBaseType.Value, posts[i].type),
			"level": posts[i].target_level(),
		})
