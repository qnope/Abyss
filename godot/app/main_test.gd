extends TestCase
## The main scene shows the title on the abyss background.

const MainScene := preload("res://app/main.tscn")
const Main := preload("res://app/main.gd")

var _main: Control


func before_each() -> void:
	_main = MainScene.instantiate() as Control
	(Engine.get_main_loop() as SceneTree).root.add_child(_main)


func after_each() -> void:
	_main.free()


func test_shows_the_title_in_rajdhani_bold() -> void:
	var title := _main.get_node("Title") as Label
	assert_eq(title.text, "ABYSSES")
	assert_eq(
		title.get_theme_font("font").resource_path,
		"res://assets/fonts/rajdhani/Rajdhani-Bold.ttf"
	)
	assert_eq(title.get_theme_color("font_color"), Main.TITLE_COLOR)


func test_paints_the_abyss_background() -> void:
	var background := _main.get_node("Background") as ColorRect
	assert_eq(background.color, Color("0a0e1a"))
