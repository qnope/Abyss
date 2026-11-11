class_name UnitTransferDialog
extends AbyssDialog
## A dialog picking how many units of each type to move out of a stock
## (lib/presentation/widgets/unit/unit_transfer_dialog.dart): a title, an
## optional subtitle, picture and notice, one [UnitQuantityRow] per type in
## stock and a confirm button written with the total picked, dark while none
## is. Confirming tells [signal confirmed] with the picks that are not zero
## and ends the dialog with them; cancelling ends it with null.
##
## The picking is the dialog's, not the game's: what moves the units (a
## descent, a garrison, reinforcements) is the owner's, on [signal confirmed].

## The player confirmed: [param picks] are the units picked, by type, none zero.
signal confirmed(picks: Dictionary[UnitType.Value, int])

## What the confirm button stands for until the dialog turns it into the picks.
const CONFIRM := &"confirm"
const GAP := 12

var available: Dictionary[UnitType.Value, Unit]
## The units picked, by type: the types touched, zero included.
var picked: Dictionary[UnitType.Value, int] = {}
var rows: Dictionary[UnitType.Value, UnitQuantityRow] = {}
var confirm_button: Button
## What the confirm button says for a total (the picks' count).
var _confirm_label: Callable


## A dialog of [param title_text] over the units [param available]. The
## [param confirm_label] gives the button's text for a total; the
## [param subtitle], [param illustration] and [param notice] come before the
## rows when given.
func _init(
	title_text: String, available_: Dictionary[UnitType.Value, Unit], confirm_label: Callable,
	subtitle := "", illustration: Control = null, notice: Control = null,
) -> void:
	super(title_text)
	available = available_
	_confirm_label = confirm_label
	body.add_theme_constant_override(&"separation", GAP)
	if illustration != null or not subtitle.is_empty():
		body.add_child(_header(subtitle, illustration))
	if notice != null:
		body.add_child(notice)
	var stocked := false
	for type: UnitType.Value in available:
		if available[type].count > 0:
			stocked = true
			rows[type] = UnitQuantityRow.new(type, available[type].count)
			rows[type].changed.connect(_pick.bind(type))
			body.add_child(rows[type])
	if not stocked:
		var none := Label.new()
		none.text = Texts.t(&"unitNoneAvailable")
		body.add_child(none)
	add_action(Texts.t(&"commonCancel"))
	confirm_button = add_action(_confirm_text(0), CONFIRM, &"")
	confirm_button.disabled = true


## The units picked that are not zero, by type.
func picks() -> Dictionary[UnitType.Value, int]:
	var found: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in picked:
		if picked[type] > 0:
			found[type] = picked[type]
	return found


## The total of the picks.
func total() -> int:
	var sum := 0
	for count: int in picks().values():
		sum += count
	return sum


## Turns the confirm button into the picks it stands for, and tells them.
func close(result: Variant = null) -> void:
	if is_closed():
		return
	if result == CONFIRM:
		var chosen := picks()
		confirmed.emit(chosen)
		super(chosen)
		return
	super(result)


func _pick(count: int, type: UnitType.Value) -> void:
	picked[type] = count
	confirm_button.text = _confirm_text(total())
	confirm_button.disabled = total() == 0


func _header(subtitle: String, illustration: Control) -> HBoxContainer:
	var header := HBoxContainer.new()
	header.add_theme_constant_override(&"separation", GAP)
	if illustration != null:
		header.add_child(illustration)
	var text := Label.new()
	text.text = subtitle
	text.theme_type_variation = &"BodySmall"
	text.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(text)
	return header


func _confirm_text(count: int) -> String:
	var text: String = _confirm_label.call(count)
	return text
