class_name AbyssChipTheme
## The chips of lib/presentation/widgets/map/level_selector.dart (`_LevelChip`):
## a small button for a choice among a few, as the depths of the map. The one
## on show is filled with cyan ([constant ACTIVE]), the others lie on the dim
## surface in cyan ink ([constant CHIP]) and a chip that cannot be chosen is
## darker, its ink disabled. Both are variations of Button, the label at 13.

const CHIP := &"ChipButton"
const ACTIVE := &"ChipButtonActive"
const FONT_SIZE := 13
const RADIUS := 8
const PADDING := Vector2i(8, 8)


## Adds the chips to [param theme].
static func apply(theme: Theme) -> void:
	var resting := AbyssButtonLook.new(
		AbyssColors.SURFACE_DIM, AbyssColors.BIOLUM_CYAN, RADIUS, PADDING,
		AbyssColors.TRENCH, AbyssColors.DISABLED
	)
	var lit := AbyssButtonLook.new(
		AbyssColors.BIOLUM_CYAN, AbyssColors.ABYSS_BLACK, RADIUS, PADDING,
		AbyssColors.TRENCH, AbyssColors.DISABLED
	)
	resting.apply_to(theme, CHIP)
	lit.apply_to(theme, ACTIVE)
	for type: StringName in [CHIP, ACTIVE]:
		theme.set_font_size(&"font_size", type, FONT_SIZE)
