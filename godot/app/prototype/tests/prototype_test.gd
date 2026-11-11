extends TestCase
## The startup screen: the game's theme on the window, the base in 3D, the
## frame counter and the quality panel over it, its choices applied, and a
## bench when the launch asks for one.

const MainScene := preload("res://app/main.tscn")

var _main: Control


func before_each() -> void:
	_main = MainScene.instantiate() as Control
	_window().add_child(_main)


func after_each() -> void:
	_main.free()
	_window().theme = null
	_window().use_hdr_2d = false
	_window().scaling_3d_scale = 1.0
	AppLocale.debug_reset()


func test_gives_the_window_the_abyss_theme() -> void:
	var theme := _window().theme
	assert_not_null(theme)
	assert_eq(theme.get_type_variation_base("HudPanel"), &"PanelContainer")


func test_speaks_the_language_of_the_player_or_the_device() -> void:
	var main := _main as Object
	var language: LanguageSettings = main.get("language")
	var locale: AppLocale = main.get("locale")
	assert_eq(language.path, LanguageSettings.PATH)
	assert_eq(locale.locale(), AppLocale.resolve(language.choice(), OS.get_locale_language()))
	assert_eq(TranslationServer.get_locale(), locale.locale())


func test_opens_on_the_base_seen_from_the_game_view() -> void:
	var base := _main.get_node("Base") as BaseScene
	assert_true(base.camera.current)
	assert_eq(base.buildings.names(), BaseScene.BUILT)
	assert_eq(_main.mouse_filter, Control.MOUSE_FILTER_IGNORE, "the touches reach the camera")


func test_fits_the_base_under_the_counter() -> void:
	var base := _main.get_node("Base") as BaseScene
	var counter := _main.get_node("Hud/Top/FrameCounter") as FrameCounter
	counter.size.y += 10.0
	var size := _main.get_viewport_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, counter.get_global_rect().end.y / size.y)
	assert_almost_eq(base.camera.rig.default_distance, fitted.x, 1e-4)
	assert_almost_eq(base.camera.rig.lift, fitted.y, 1e-4)


func test_shows_the_counter_in_the_theme() -> void:
	var counter := _main.get_node("Hud/Top/FrameCounter") as FrameCounter
	var headline := counter.line(0)
	assert_eq(headline.get_theme_color("font_color"), AbyssColors.BIOLUM_CYAN)
	assert_eq(headline.get_theme_font_size("font_size"), 20)


func test_applies_the_quality_chosen() -> void:
	var quality := _main.get_node("Hud/Top/QualityPanel") as QualityPanel
	quality.button(QualityPanel.SHADOWS).button_pressed = false
	quality.button(QualityPanel.SCALE, 0.75).button_pressed = true
	assert_false((_main.get_node("Base") as BaseScene).key_light.shadow_enabled)
	assert_eq(_window().scaling_3d_scale, 0.75)


func test_keeps_the_panels_off_the_screen_s_edges() -> void:
	var hud := _main.get_node("Hud") as MarginContainer
	assert_true(hud.get_theme_constant("margin_top") >= 10)
	assert_eq(hud.get_theme_constant("margin_left"), 10)


func test_runs_a_bench_uncapped_when_asked() -> void:
	_main.call(&"start_bench", BenchOptions.new(0.0))
	assert_eq(_main.find_children("*", "BenchRun", false, false).size(), 0)
	_main.call(&"start_bench", BenchOptions.new(10.0))
	assert_eq(_main.find_children("*", "BenchRun", false, false).size(), 1)
	var idle := _main.find_children("*", "IdleFrameCap", false, false)[0] as IdleFrameCap
	assert_false(idle.enabled)


func _window() -> Window:
	return (Engine.get_main_loop() as SceneTree).root
