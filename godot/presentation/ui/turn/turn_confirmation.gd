class_name TurnConfirmation
extends AbyssDialog
## The question before a turn ends (lib/presentation/widgets/turn/
## turn_confirmation_dialog.dart): "Tour 3 → Tour 4", what the base will make,
## the scouts still out, the buildings the lack of energy will shut down, the
## units the lack of algae will take, and the warnings of [TurnWarnings].
## It ends with true when the player confirms, false when they cancel, null
## when they dismiss it.

var forecast: TurnForecast
var empty_label := Label.new()
var explorations_line: SummaryLine
var cancel_button: Button
var confirm_button: Button


func _init(forecast_: TurnForecast, warnings: Array[Control] = []) -> void:
	forecast = forecast_
	super()
	var quiet := forecast.production.is_empty() and forecast.buildings_to_deactivate.is_empty() \
			and forecast.units_to_lose.is_empty() and warnings.is_empty()
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.visible = quiet
	body.add_child(empty_label)
	if not quiet:
		_fill(warnings)
	cancel_button = add_action("", false)
	confirm_button = add_action("", true, &"")
	refresh()


func refresh() -> void:
	# Called once by the base class, before the buttons are made.
	if confirm_button == null:
		return
	set_title(Texts.t(&"turnTransition", {"from": forecast.turn, "to": forecast.turn + 1}))
	empty_label.text = Texts.t(&"turnNoProduction")
	cancel_button.text = Texts.t(&"commonCancel")
	confirm_button.text = Texts.t(&"commonConfirm")


func _fill(warnings: Array[Control]) -> void:
	for type in forecast.production:
		body.add_child(ResourceChangeLine.new(type, forecast.production[type]))
	if forecast.pending_explorations > 0:
		body.add_child(HSeparator.new())
		explorations_line = SummaryLine.new(&"explore", AbyssColors.BIOLUM_CYAN,
			Texts.t.bind(&"turnPendingExplorations", {"count": forecast.pending_explorations}))
		body.add_child(explorations_line)
	if not forecast.buildings_to_deactivate.is_empty():
		body.add_child(TurnLosses.deactivated(forecast.buildings_to_deactivate))
	if not forecast.units_to_lose.is_empty():
		body.add_child(TurnLosses.lost_units(forecast.units_to_lose))
	for warning in warnings:
		body.add_child(warning)
