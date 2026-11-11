class_name ArmySelection
extends FullPage
## The page where the army to send is picked
## (lib/presentation/screens/game/fight/army_selection_screen.dart), whatever
## it is sent against: a header (what is attacked), a [UnitQuantityRow] for each
## type in stock, the totals the units will fight with ([SelectionSummaryCard])
## and the launch and cancel buttons ([ArmySelectionActions]).
##
## The page picks and asks; it changes nothing. Launching calls the
## [param confirm] it was given with the picks (counts by type, none zero) and
## expects an [ActionResult]: a success ends the page with it, a refusal is told
## in the page, which stays open. Cancelling, or the back arrow, ends it with
## null.
##
## An assault is led by an Abyss Admiral ([param needs_admiral]): the page
## warns of it while none is picked and launches only with one. A plan of the
## assault (`../assault/AssaultPlans`) follows the picks on [signal picks_changed].

## The units picked changed: [param chosen] are the ones that are not zero.
signal picks_changed(chosen: Dictionary[UnitType.Value, int])

const GAP := 12

var available: Dictionary[UnitType.Value, Unit]
var boost: UnitBoost
var needs_admiral: bool
## The units picked, by type: the types touched, zero included.
var picked: Dictionary[UnitType.Value, int] = {}
var rows: Dictionary[UnitType.Value, UnitQuantityRow] = {}
var summary: SelectionSummaryCard
var actions_bar: ArmySelectionActions
## Why the last launch was refused, hidden until there was one.
var failure_label := Label.new()
var _title: Callable
var _confirm: Callable
var _failure: ActionResult


## A page titled with what [param title_] returns, over the units
## [param available_] (the stock of the place they leave, with zero counts
## left out), fought with [param boost_]. The button of [param launch_key]
## calls [param confirm_] (taking the picks, returning an [ActionResult]);
## [param header] comes before the rows.
func _init(
	title_: Callable, available_: Dictionary[UnitType.Value, Unit], boost_: UnitBoost,
	launch_key: StringName, confirm_: Callable, header: Control = null, needs_admiral_ := false,
) -> void:
	_title = title_
	_confirm = confirm_
	super()
	available = available_
	boost = boost_
	needs_admiral = needs_admiral_
	body.add_theme_constant_override(&"separation", GAP)
	if header != null:
		body.add_child(header)
	for type: UnitType.Value in available:
		if available[type].count > 0:
			rows[type] = UnitQuantityRow.new(type, available[type].count)
			rows[type].changed.connect(_pick.bind(type))
			body.add_child(rows[type])
	summary = SelectionSummaryCard.new(boost)
	body.add_child(summary)
	failure_label.theme_type_variation = &"BodySmall"
	failure_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	failure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	failure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	failure_label.visible = false
	body.add_child(failure_label)
	actions_bar = ArmySelectionActions.new(launch_key)
	actions_bar.launch_requested.connect(launch)
	actions_bar.cancel_requested.connect(close)
	body.add_child(actions_bar)
	actions_bar.set_admiral_missing(needs_admiral)
	refresh()


## The units picked that are not zero, by type.
func picks() -> Dictionary[UnitType.Value, int]:
	var found: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in picked:
		if picked[type] > 0:
			found[type] = picked[type]
	return found


## Asks the owner to send the units picked: the page ends with the answer when
## it is a success, and tells why when it is not.
func launch() -> void:
	var answer: ActionResult = _confirm.call(picks())
	if answer.is_success:
		close(answer)
		return
	_failure = answer
	refresh()


func refresh() -> void:
	set_title(str(_title.call()))
	failure_label.visible = _failure != null
	if _failure != null:
		failure_label.text = ActionFailureTexts.failure_message(_failure)


func _pick(count: int, type: UnitType.Value) -> void:
	picked[type] = count
	var chosen := picks()
	summary.show_totals(ArmySelectionSummary.total_atk(chosen, boost), ArmySelectionSummary.total_def(chosen, boost))
	var led: bool = not needs_admiral or chosen.get(UnitType.Value.ABYSS_ADMIRAL, 0) > 0
	actions_bar.set_admiral_missing(not led)
	actions_bar.set_ready(not chosen.is_empty() and led)
	_failure = null
	refresh()
	picks_changed.emit(chosen)
