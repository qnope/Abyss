class_name TipStack
extends ModalPanel
## The « première fois » tips that arrive together (lib/.../tip_stack.dart),
## one card at a time: "Suivant" or a swipe goes through them, "n / m" tells
## where the player is, and the last card closes the stack. The cards that
## peek out behind the front one in Flutter are not drawn.

## The travel of a drag, in pixels, from which it is a swipe.
const SWIPE := 60.0

var tips: Array[Tip]
var index := 0
## The card on show.
var card: IllustratedCardBody
## "n / m", null for a stack of one.
var count_label: Label
## Kept from one card to the next: it is the one being pressed.
var next_button := Button.new()
var _scroll := ScrollBody.new()
var _drag_from := 0.0


func _init(tips_: Array[Tip]) -> void:
	tips = tips_
	super()
	placement = Placement.CENTER
	theme_type_variation = &"DialogPanel"
	next_button.pressed.connect(_advance)
	add_child(_scroll)
	refresh()


func fit(area: Vector2) -> void:
	custom_minimum_size.x = AbyssDialog.width_in(area)
	var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
	_scroll.max_height = maxf(area.y * AbyssDialog.MAX_HEIGHT_SHARE - chrome, 0.0)


## Goes to the card [param next]; nothing when it is out of the stack.
func go(next: int) -> void:
	if next >= 0 and next < tips.size():
		index = next
		refresh()


## Writes the card on show again, in the language on.
func refresh() -> void:
	# Called once by the base class, before there are tips to show.
	if tips.is_empty():
		return
	if next_button.get_parent() != null:
		next_button.get_parent().remove_child(next_button)
	for old in _scroll.content.get_children():
		_scroll.content.remove_child(old)
		old.free()
	var id := tips[index].id
	card = IllustratedCardBody.new(TipIllustrations.new().of(id, IllustratedCardBody.ILLUSTRATION_SIZE),
			TipTexts.title(id), TipTexts.lines(id))
	count_label = null
	if tips.size() > 1:
		count_label = card.add_note("%d / %d" % [index + 1, tips.size()], AbyssColors.ON_SURFACE_DIM)
	var closes := index == tips.size() - 1
	next_button.text = Texts.t(&"commonGotIt" if closes else &"commonNext")
	card.add_action(next_button)
	_scroll.content.add_child(card)


func _gui_input(event: InputEvent) -> void:
	var touch := event as InputEventMouseButton
	if touch == null or touch.button_index != MOUSE_BUTTON_LEFT:
		return
	if touch.pressed:
		_drag_from = touch.position.x
	else:
		swipe(touch.position.x - _drag_from)


## A drag of [param travel] pixels: left goes on, right goes back.
func swipe(travel: float) -> void:
	if travel <= -SWIPE:
		go(index + 1)
	elif travel >= SWIPE:
		go(index - 1)


func _advance() -> void:
	if index == tips.size() - 1:
		close()
	else:
		go(index + 1)
