class_name OpeningStoryScreen
extends RefreshingPanel
## The opening story told over the dimmed world as a new game begins, before
## its first turn (lib/presentation/screens/menu/opening_story_screen.dart).
## Going back skips it, as "Passer" does; [signal finished] is told once only.

signal finished

var pager: StoryPager


func _init() -> void:
	super()
	var veil := Panel.new()
	veil.theme_type_variation = AbyssSurfaceTheme.SCRIM
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var centre := CenterContainer.new()
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pager = StoryPager.new(OpeningStory.pages, &"openingStoryDive")
	pager.done.connect(finished.emit)
	centre.add_child(pager)
	add_child(veil)
	add_child(centre)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		pager.finish()
		get_viewport().set_input_as_handled()
