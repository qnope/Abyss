class_name IllustratedCard
extends ModalPanel
## The dialog of a card with a picture (lib/.../illustrated_card.dart): its
## [IllustratedCardBody] in a dialog, the actions ending it with their result.
##
##     var card := IllustratedCard.new(UiIcon.new(path, IllustratedCard.ILLUSTRATION_SIZE),
##             title, PackedStringArray([line]))
##     card.add_action(Texts.t(&"commonGotIt"), true, &"")
##     layer.open(card)

const ILLUSTRATION_SIZE := IllustratedCardBody.ILLUSTRATION_SIZE

var card_body: IllustratedCardBody
var _scroll := ScrollBody.new()


func _init(illustration: Control, title: String, lines: PackedStringArray) -> void:
	super()
	placement = Placement.CENTER
	theme_type_variation = &"DialogPanel"
	card_body = IllustratedCardBody.new(illustration, title, lines)
	_scroll.content.add_child(card_body)
	add_child(_scroll)


## Adds a button that ends the card with [param result] when pressed, in the
## Button variation [param variation] (&"" for the filled one).
func add_action(label: String, result: Variant = null, variation := &"") -> Button:
	var button := Button.new()
	button.text = label
	button.theme_type_variation = variation
	button.pressed.connect(close.bind(result))
	card_body.add_action(button)
	return button


func fit(area: Vector2) -> void:
	custom_minimum_size.x = AbyssDialog.width_in(area)
	var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
	_scroll.max_height = maxf(area.y * AbyssDialog.MAX_HEIGHT_SHARE - chrome, 0.0)
