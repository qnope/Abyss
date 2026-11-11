class_name EventCard
extends IllustratedCard
## The dialog that announces a random event: its illustration, its name, two
## lines telling what happens and its options, figures included
## (lib/presentation/widgets/event/event_card.dart, and
## screens/game/game_screen_event_actions.dart: openEventCard).
##
## An event with a choice offers the first option (filled; closed, with its
## reason under it, when the stock or the state forbids it), the prudent one
## (outlined) and "later". A choice goes through the [GameActions]
## ([ChooseEventAction]): a success ends the card with the option taken (true
## for the first, false for the prudent one); a refusal, which Flutter shows
## after closing the card, is told in the card, which stays open. "Later" ends
## it with null and the event stays pending. An event that only informs offers
## "Got it", and ends with null.

var actions: GameActions
var data: EventCardData
## Why the last choice was refused, shown under the options; empty if none was.
var failure_label: Label
## The buttons of the options, the first then the prudent one.
var choice_buttons: Array[Button] = []


func _init(actions_: GameActions, type: RandomEventType.Value) -> void:
	actions = actions_
	data = EventCardData.of(actions.game, type)
	var picture := UiIcon.new(RandomEventTexts.illustration(type), ILLUSTRATION_SIZE)
	super(picture, RandomEventTexts.label(type), data.lines)
	if data.choices.is_empty():
		add_action(Texts.t(&"commonGotIt"), null, &"")
		return
	for choice in data.choices:
		_add_choice(choice)
	failure_label = card_body.add_note("", AbyssColors.WARNING)
	failure_label.visible = false
	add_action(Texts.t(&"eventCardLater"), null, &"TextButton")


func _add_choice(choice: EventChoice) -> void:
	var button := Button.new()
	button.text = choice.label
	button.theme_type_variation = &"" if choice.accept else &"OutlinedButton"
	button.disabled = choice.refusal != null
	button.pressed.connect(_choose.bind(choice.accept))
	choice_buttons.append(button)
	card_body.add_action(button)
	if choice.refusal != null:
		var reason: String = choice.refusal
		card_body.add_note(reason, AbyssColors.WARNING)


func _choose(accept: bool) -> void:
	var result := actions.execute(ChooseEventAction.new(accept))
	if result.is_success:
		close(accept)
		return
	failure_label.text = ActionFailureTexts.failure_message(result)
	failure_label.visible = true
