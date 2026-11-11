class_name RivalPostSheet
extends MapSheet
## What a touch on a Faille, a Cheminée or the volcano that another player
## holds opens (lib/presentation/widgets/map/rival_post_sheet.dart): who holds
## it, why the attack is refused if it is, and the attack button.
##
## The attack itself is the rival assault of `app/game/FactionController`: the sheet only tells
## [signal attack_requested], after it closed, and its owner opens what
## follows. Without a [member base] it is the volcanic kernel that is held.

## The player wants to attack the post.
signal attack_requested

const BUTTON_GAP := 12

var base: TransitionBase
var owner_name: String
var held_label: Label
var cancel_button: Button
var attack_button: Button


## The sheet of [param base_] (null for the kernel) held by the player called
## [param owner_name_]; [param refusal] is the [ActionFailure] that forbids
## the attack now, null when it is allowed.
func _init(base_: TransitionBase, owner_name_: String, refusal: Variant) -> void:
	base = base_
	owner_name = owner_name_
	super(_picture(), _title)
	held_label = label(func() -> String: return Texts.t(&"mapHeldBy", {"name": owner_name}), &"LabelLarge")
	held_label.add_theme_color_override(&"font_color", AbyssColors.PEARL_WHITE)
	column.add_child(held_label)
	column.add_child(failure_label)
	if refusal != null:
		var reason: ActionFailure.Value = refusal
		tell(reason)
	column.add_child(HSeparator.new())
	cancel_button = button(func() -> String: return Texts.t(&"commonCancel"))
	cancel_button.theme_type_variation = &"TextButton"
	cancel_button.pressed.connect(close)
	attack_button = button(func() -> String: return Texts.t(&"factionBaseAttack"))
	attack_button.disabled = refusal != null
	attack_button.pressed.connect(_attack)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", BUTTON_GAP)
	buttons.add_child(cancel_button)
	buttons.add_child(attack_button)
	column.add_child(buttons)


func _picture() -> Control:
	if base != null:
		return PostPicture.of(base.type, PostHolder.Value.FACTION)
	return Portrait.new(BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL), PostPicture.SIZE,
		PassagePicture.tint_of(PostHolder.Value.FACTION))


func _title() -> String:
	if base != null:
		return TransitionBaseNameTexts.label(base.name)
	return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL)


func _attack() -> void:
	close()
	attack_requested.emit()
