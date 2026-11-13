class_name StorySkipButton
extends RefreshingPanel
## "Passer ›" (lib/presentation/widgets/turn/story_skip_button.dart): the button
## that floats over the map while the story of a turn is told, and ends it at
## once. It lies on deep water like every button over the map
## ([constant AbyssButtonTheme.OVER_MAP]); its text follows the language.

## The player wants the story over.
signal skipped

## How far it stands from the corner of the area it floats in.
const MARGIN := 16

var button := Button.new()


func _init() -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.theme_type_variation = AbyssButtonTheme.OVER_MAP
	button.pressed.connect(skipped.emit)
	add_child(button)
	refresh()


## Puts it in the bottom right corner of [param area], which it joins.
func float_in(area: Control) -> void:
	area.add_child(self)
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, MARGIN)


func refresh() -> void:
	button.text = Texts.t(&"turnStorySkip")
