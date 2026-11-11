class_name AbyssCardTheme
## The panels of lib/presentation/theme/abyss_card_theme.dart. The card is
## the plain PanelContainer; the dialog, the bottom sheet, the app bar and
## the save panels are its variations, with the Label variations of their
## titles. The popup menu is in AbyssPopupTheme.
##
## A Flutter card has no padding and an outer margin of 8; a Godot panel
## pads its content and leaves the gaps to its container, so the card
## pads by 16, the padding the game's cards give their content.

const PANEL := &"PanelContainer"
const CYAN := AbyssColors.BIOLUM_CYAN

## The drag handle at the top of a bottom sheet.
const DRAG_HANDLE := Color(CYAN, 0.5)
## The bar of a SheetDragHandle (lib/.../sheet_drag_handle.dart): on-surface
## at 30 %, 40 x 4, 8 above and 4 below.
const SHEET_HANDLE := Color(AbyssColors.ON_SURFACE, 0.3)
const HANDLE_SIZE := Vector2i(40, 4)
const HANDLE_PADDING := Vector2i(8, 4)
## The gap between the title, the body and the actions of a dialog or a
## sheet, and between two actions.
const GAP := 16
const ACTION_GAP := 8
const SAVE_PANEL_RADIUS := 16
const SAVE_PANEL_FILL := Color(AbyssColors.SURFACE_LIGHT, 0.78)


## Adds the panels and their titles to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_stylebox(&"panel", PANEL, card())
	_add(theme, &"DialogPanel", dialog())
	_add(theme, &"BottomSheetPanel", bottom_sheet())
	_add(theme, &"AppBarPanel", AbyssBox.flat(Color(AbyssColors.ABYSS_BLACK, 0.9), 0))
	_add(theme, &"SavePanel", save_panel(false))
	_add(theme, &"SavePanelHighlighted", save_panel(true))
	_add(theme, &"SavePanelFaded", save_panel(false, true))
	const BOLD := AbyssFonts.Weight.BOLD
	AbyssTextTheme.add_label(theme, &"AppBarTitle", AbyssTextStyle.new(20, BOLD, CYAN, 1.5))
	# In the platform's font in Flutter, at 600.
	const DEFAULT := AbyssFonts.Weight.DEFAULT
	AbyssTextTheme.add_label(theme, &"DialogTitle", AbyssTextStyle.new(20, DEFAULT, CYAN))


## Surface light, rimmed and lifted faintly in cyan.
static func card() -> StyleBoxFlat:
	var box := AbyssBox.flat(AbyssColors.SURFACE_LIGHT, 16, Vector2i(16, 16))
	return AbyssBox.lifted(AbyssBox.rimmed(box, Color(CYAN, 0.15)), Color(CYAN, 0.15), 4)


## Deep navy, rimmed in cyan, padded as a Material dialog.
static func dialog() -> StyleBoxFlat:
	var box := AbyssBox.flat(AbyssColors.DEEP_NAVY, 20, Vector2i(24, 24))
	return AbyssBox.rimmed(box, Color(CYAN, 0.2))


## Deep navy rising from the bottom edge, its top rounded.
static func bottom_sheet() -> StyleBoxFlat:
	return AbyssBox.top_rounded(AbyssBox.flat(AbyssColors.DEEP_NAVY, 0, Vector2i(16, 16)), 24)


## The panel of a save card, lighter when [param faded]. A
## [param highlighted] panel glows cyan: the game a player most likely
## resumes.
static func save_panel(highlighted: bool, faded := false) -> StyleBoxFlat:
	var fill := AbyssColors.dimmed(SAVE_PANEL_FILL) if faded else SAVE_PANEL_FILL
	var box := AbyssBox.flat(fill, SAVE_PANEL_RADIUS, Vector2i(16, 16))
	if highlighted:
		return AbyssBox.glowing(AbyssBox.rimmed(box, Color(CYAN, 0.75), 1.5), Color(CYAN, 0.22), 18)
	return AbyssBox.rimmed(box, Color(CYAN, 0.08 if faded else 0.18))


static func _add(theme: Theme, name: StringName, panel: StyleBoxFlat) -> void:
	theme.set_type_variation(name, PANEL)
	theme.set_stylebox(&"panel", name, panel)
