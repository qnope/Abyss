extends TestCase
## The main scene gives the window the game's theme and shows the title
## on the abyss background.

const MainScene := preload("res://app/main.tscn")

var _main: Control


func before_each() -> void:
	_main = MainScene.instantiate() as Control
	_window().add_child(_main)


func after_each() -> void:
	_main.free()
	_window().theme = null


func test_gives_the_window_the_abyss_theme() -> void:
	var theme := _window().theme
	assert_not_null(theme)
	assert_eq(theme.get_type_variation_base("HeroTitle"), &"Label")


func test_shows_the_title_in_the_hero_style() -> void:
	var title := _main.get_node("Title") as Label
	assert_eq(title.text, "ABYSSES")
	assert_eq(title.theme_type_variation, &"HeroTitle")
	assert_eq((title.get_theme_font("font") as FontVariation).base_font, AbyssFonts.BOLD)
	assert_eq(title.get_theme_font_size("font_size"), 60)
	assert_eq(title.get_theme_color("font_color"), AbyssColors.BIOLUM_CYAN)


func test_paints_the_abyss_background() -> void:
	var background := _main.get_node("Background") as ColorRect
	assert_eq(background.color, AbyssColors.ABYSS_BLACK)


func _window() -> Window:
	return (Engine.get_main_loop() as SceneTree).root
