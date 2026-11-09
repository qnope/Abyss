class_name AbyssPopupTheme
## What pops over a screen: the popup menu of
## lib/presentation/theme/abyss_card_theme.dart and the tooltip of
## abyss_theme.dart, on the PopupMenu and Tooltip types.

const MENU := &"PopupMenu"
## Height of a menu item, a touch target in Material 3.
const MENU_ITEM_HEIGHT := 48
const MENU_ELEVATION := 6


## Adds the popup menu and the tooltip to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_stylebox(&"panel", MENU, menu())
	theme.set_stylebox(&"hover", MENU, AbyssBox.flat(Color(AbyssColors.ON_SURFACE, 0.08), 0))
	var label := AbyssTextTheme.button_label()
	theme.set_font(&"font", MENU, label.font())
	theme.set_font_size(&"font_size", MENU, label.size)
	for state: String in ["font", "font_hover", "font_accelerator"]:
		theme.set_color(state + "_color", MENU, AbyssColors.ON_SURFACE)
	theme.set_color(&"font_disabled_color", MENU, AbyssButtonTheme.DISABLED_INK)
	theme.set_constant(&"item_start_padding", MENU, 12)
	theme.set_constant(&"item_end_padding", MENU, 12)
	var line := ceili(label.font().get_height(label.size))
	theme.set_constant(&"v_separation", MENU, MENU_ITEM_HEIGHT - line)
	theme.set_stylebox(&"panel", &"TooltipPanel", tooltip())
	theme.set_color(&"font_color", &"TooltipLabel", AbyssColors.ON_SURFACE)
	theme.set_font_size(&"font_size", &"TooltipLabel", 12)


## Deep navy, rimmed in cyan, lifted over the screen.
static func menu() -> StyleBoxFlat:
	var box := AbyssBox.flat(AbyssColors.DEEP_NAVY, 12, Vector2i(0, 8))
	var rimmed := AbyssBox.rimmed(box, Color(AbyssColors.BIOLUM_CYAN, 0.2))
	return AbyssBox.lifted(rimmed, Color.BLACK, MENU_ELEVATION)


## A small bright panel rimmed in cyan, padded as a Material tooltip on
## a phone.
static func tooltip() -> StyleBoxFlat:
	var box := AbyssBox.flat(AbyssColors.SURFACE_BRIGHT, 8, Vector2i(16, 4))
	return AbyssBox.rimmed(box, Color(AbyssColors.BIOLUM_CYAN, 0.3))
