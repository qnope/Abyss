class_name ThreatReportPage
extends FullPage
## The page of a fight against a threat, after the summary of the turn: a
## title, the cards of the report one under the other, and "back to the base"
## to close it. The raid and the kraken wave fill it with their own cards
## (lib/presentation/screens/game/raid/raid_summary_screen.dart and
## volcano/volcano_summary_screen.dart). It ends with null.

const GAP := 12

var base_button := Button.new()
var _title: Callable


## A page titled with what [param title] returns, in the language on.
func _init(title: Callable) -> void:
	_title = title
	super()
	body.add_theme_constant_override(&"separation", GAP)
	base_button.pressed.connect(close)
	refresh()


func refresh() -> void:
	set_title(str(_title.call()))
	base_button.text = Texts.t(&"commonBackToBase")


## Puts [param card] under the ones already there.
func add_card(card: Control) -> void:
	body.add_child(card)


## Puts the button that closes the page under the last card.
func add_back_button() -> void:
	body.add_child(base_button)
