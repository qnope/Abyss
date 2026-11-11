extends TestCase
## The game's theme gathers every family of styles into one Theme.

var _theme: Theme


func before_each() -> void:
	_theme = AbyssTheme.build()


func test_gathers_every_family() -> void:
	assert_eq(_theme.default_font_size, 14)
	for variation: String in [
		"TitleLarge", "OutlinedButton", "DialogPanel", "ErrorLineEdit",
		"SegmentedTray", "Segment", "HeroTitle", "MenuPrimaryButton", "HudPanel",
		"ModalScrim", "BarePanel", "TapSurface", "Switch", "SnackBarPanel", "NavigationItem",
	]:
		assert_ne(_theme.get_type_variation_base(variation), &"", variation)
	assert_true(_theme.has_stylebox("panel", "PopupMenu"))
	assert_true(_theme.has_stylebox("panel", "TooltipPanel"))
	assert_true(_theme.has_stylebox("panel", "PanelContainer"))
	assert_true(_theme.has_stylebox("normal", "Button"))
	assert_true(_theme.has_stylebox("normal", "LineEdit"))


func test_builds_a_new_theme_each_time() -> void:
	assert_ne(AbyssTheme.build(), _theme)
