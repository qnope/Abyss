class_name TechChoiceRow
extends HBoxContainer
## The two exclusive options of a choice node, face to face
## (lib/presentation/widgets/tech/tech_choice_row.dart). [signal chosen] tells
## the option whose button was pressed.

## The player took [param option].
signal chosen(option: TechOption.Value)

const GAP := 6

var cards: Dictionary[TechOption.Value, TechOptionCard] = {}


## The options of the choice node of [param level] of [param branch];
## [param taken] is the TechOption already taken, null while the node is not
## researched, and [param enabled] lets the buttons be pressed.
func _init(branch: TechBranch.Value, level: int, taken: Variant, enabled: bool) -> void:
	add_theme_constant_override(&"separation", GAP)
	for option: TechOption.Value in TechOption.Value.values():
		var status := TechOptionCard.Status.OPEN
		if taken != null:
			status = TechOptionCard.Status.TAKEN if taken == option else TechOptionCard.Status.DISCARDED
		var card := TechOptionCard.new(branch, level, option, status, enabled)
		card.choose_pressed.connect(chosen.emit.bind(option))
		cards[option] = card
		add_child(card)
		if option == TechOption.Value.A:
			var or_label := Label.new()
			or_label.text = Texts.t(&"techScreenOr")
			or_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			add_child(or_label)
