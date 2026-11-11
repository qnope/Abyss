class_name ObjectiveStatus
extends RefCounted
## Where an objective stands in the list of objectives
## (lib/.../objective_row.dart, ObjectiveStatus): its glyph and the colours of
## its title and its glyph.

enum Value {
	## Completed.
	DONE,
	## The one the player is on.
	CURRENT,
	## Still to come.
	TO_DO,
	## Set by an event for a while.
	TEMPORARY,
}


## The file of the glyph of [param status].
static func glyph(status: Value) -> StringName:
	match status:
		Value.DONE:
			return &"check_circle"
		Value.CURRENT:
			return &"flag"
		Value.TO_DO:
			return &"radio_button_unchecked"
	return &"hourglass_bottom"


## The colour of the title of [param status].
static func text_color(status: Value) -> Color:
	match status:
		Value.DONE:
			return AbyssColors.ON_SURFACE_DIM
		Value.CURRENT:
			return AbyssColors.BIOLUM_CYAN
		Value.TO_DO:
			return AbyssColors.ON_SURFACE
	return AbyssColors.WARNING


## The colour of the glyph of [param status].
static func icon_color(status: Value) -> Color:
	match status:
		Value.DONE:
			return AbyssColors.SUCCESS
		Value.CURRENT:
			return AbyssColors.BIOLUM_CYAN
		Value.TO_DO:
			return AbyssColors.ON_SURFACE_DIM
	return AbyssColors.WARNING
