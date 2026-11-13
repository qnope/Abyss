class_name StoryPager
extends RefreshingPanel
## Tells pages card after card (lib/presentation/widgets/opening/story_pager.dart):
## "Suivant" or a swipe turns them, the button of the last one, labelled with
## the label it is given, ends the story and "Passer" ends it from any card.
## [signal done] is told once only.

signal done

## Widest a card grows, on a tablet or a desktop window.
const MAX_WIDTH := 440.0
## How far a swipe goes at least, in points.
const SWIPE := 60.0
const DOT_HEIGHT := 6
const DOT_WIDTH := 6
const CURRENT_DOT_WIDTH := 18

var pages: Array[StoryPage]
var index := 0
var card := StoryCard.new()
var next_button := Button.new()
var skip_button := Button.new()
var _source: Callable
var _done_key: StringName
var _is_done := false
var _dots := HBoxContainer.new()
var _press := Vector2.ZERO


## [param source] gives the pages in the language on, again when it changes;
## the last card's button says the text of [param done_key].
func _init(source: Callable, done_key: StringName) -> void:
	super()
	_source = source
	_done_key = done_key
	pages = source.call()
	custom_minimum_size.x = MAX_WIDTH
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in pages.size():
		_dots.add_child(Panel.new())
	skip_button.theme_type_variation = &"TextButton"
	next_button.pressed.connect(_on_next)
	skip_button.pressed.connect(finish)
	card.footer.add_child(_dots)
	card.footer.add_child(next_button)
	card.footer.add_child(skip_button)
	add_child(card)
	gui_input.connect(_on_input)
	refresh()


## Shows card [param at], if there is one.
func go(at: int) -> void:
	if at < 0 or at >= pages.size():
		return
	index = at
	refresh()


## Ends the story, once.
func finish() -> void:
	if _is_done:
		return
	_is_done = true
	done.emit()


func refresh() -> void:
	# Called once by the base class, before there are pages to show.
	if _source.is_null():
		return
	pages = _source.call()
	var last := index == pages.size() - 1
	card.show_page(pages[index])
	next_button.text = Texts.t(_done_key) if last else Texts.t(&"commonNext")
	skip_button.text = Texts.t(&"openingStorySkip")
	skip_button.visible = not last
	for i in _dots.get_child_count():
		_paint_dot(_dots.get_child(i) as Panel, i == index)


func _on_next() -> void:
	if index == pages.size() - 1:
		finish()
	else:
		go(index + 1)


## A finger's swipe, read before the controls under it: a card's own
## controls take the press, and a phone's finger never reaches [signal gui_input].
func _input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch == null or touch.index != 0 or not is_visible_in_tree():
		return
	var local: InputEventScreenTouch = make_input_local(touch)
	if touch.pressed:
		_press = local.position
	elif Rect2(Vector2.ZERO, size).has_point(_press):
		_swipe(local.position.x - _press.x)


## A swipe to the left shows the next card, to the right the previous one;
## the mouse of a desktop, not the one a touch emulates.
func _on_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click == null or click.button_index != MOUSE_BUTTON_LEFT \
			or click.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if click.pressed:
		_press = click.position
	else:
		_swipe(click.position.x - _press.x)


func _swipe(dx: float) -> void:
	if dx <= -SWIPE:
		go(index + 1)
	elif dx >= SWIPE:
		go(index - 1)


func _paint_dot(dot: Panel, lit: bool) -> void:
	var colour := AbyssColors.BIOLUM_CYAN if lit else AbyssColors.DISABLED
	dot.add_theme_stylebox_override(&"panel", AbyssBox.flat(colour, 3))
	dot.custom_minimum_size = Vector2(CURRENT_DOT_WIDTH if lit else DOT_WIDTH, DOT_HEIGHT)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
