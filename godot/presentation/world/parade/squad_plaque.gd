class_name SquadPlaque
extends Label3D
## What is written over a squad (the plaque of the Flutter parade): how many
## units serve, in the squad's colour, and its caption under it; a locked
## squad has but its caption (the barracks level it waits for). Facing the
## camera and drawn over the figures, like the level of a building.

const FONT_SIZE := 72
const OUTLINE := 18
## A glyph's height in metres at [constant FONT_SIZE].
const PIXEL_SIZE := 0.0055


func _init() -> void:
	name = &"Plaque"
	font_size = FONT_SIZE
	outline_size = OUTLINE
	pixel_size = PIXEL_SIZE
	outline_modulate = WorldPalette.LEVEL_OUTLINE
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 2
	shaded = false


## Writes the plaque of [param state]: faint while the squad is empty or
## locked.
func show_state(state: SquadState) -> void:
	text = state.caption if state.locked else "%d\n%s" % [state.count, state.caption]
	var faint := state.locked or state.count == 0
	modulate = Color(WorldPalette.unit(state.type), WorldPalette.EMPTY_SQUAD if faint else 1.0)
