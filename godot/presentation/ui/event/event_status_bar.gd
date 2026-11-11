class_name EventStatusBar
extends RefreshingPanel
## The thin strip under the raid and volcano bars: the event waiting for a
## choice, which reopens its card when touched, the effect that lasts and the
## wreck left on the map; hidden when there is none
## (lib/presentation/widgets/event/event_status_bar.dart, and
## game_screen.dart: _openPendingEvent). It is read again from the game by
## [method refresh], which the game screen's status bars call on each change
## and the language on its own.
##
## Touching the pending line opens the [EventCard] of the event on the modals;
## the choice goes through the actions, which save and redraw.

const PADDING := Vector2i(12, 3)
const GAP := 2

var actions: GameActions
var pending_line := StripLine.new(&"auto_awesome", AbyssColors.BIOLUM_CYAN)
var effect_line := StripLine.new(&"hourglass_bottom", AbyssColors.WARNING)
var wreck_line := StripLine.new(&"hourglass_bottom", AbyssColors.WARNING)
## The touch area over the pending line.
var tap_button := Button.new()
var _modals: ModalLayer
var _pending: Variant = null


func _init(actions_: GameActions, modals: ModalLayer) -> void:
	actions = actions_
	_modals = modals
	super()
	add_theme_stylebox_override(&"panel", AbyssBox.flat(AbyssColors.SURFACE_DIM, 0, PADDING))
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var pending := PanelContainer.new()
	pending.theme_type_variation = AbyssSurfaceTheme.BARE
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.pressed.connect(_open_card)
	pending.add_child(pending_line)
	pending.add_child(tap_button)
	column.add_child(pending)
	column.add_child(effect_line)
	column.add_child(wreck_line)
	add_child(column)
	refresh()


func refresh() -> void:
	var state := actions.game.human_player().event_state
	var turn := actions.game.turn
	_pending = state.pending if state.has_pending() else null
	if _pending == null:
		pending_line.show_text(null)
	else:
		var type: RandomEventType.Value = _pending
		pending_line.show_text(Texts.t(&"eventCardStatusPending", {"event": RandomEventTexts.label(type)}))
	tap_button.accessibility_name = pending_line.label.text
	effect_line.show_text(EventStateTexts.effect_countdown(state, turn))
	wreck_line.show_text(EventStateTexts.wreck_countdown(state, turn))
	visible = pending_line.visible or effect_line.visible or wreck_line.visible


func _open_card() -> void:
	if _pending == null:
		return
	var type: RandomEventType.Value = _pending
	_modals.open(EventCard.new(actions, type))
