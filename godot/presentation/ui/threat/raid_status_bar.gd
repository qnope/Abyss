class_name RaidStatusBar
extends ThreatStrip
## The strip under the resource bar that shows the noise gauge, or the alert of
## the raid on its way, and the raids lost in a row when there are some
## (lib/presentation/widgets/raid/raid_status_bar.dart).

const ICON_SIZE := 16.0
const ALERT_ICON_SIZE := 18.0
const GAUGE_HEIGHT := 6.0

var game: Game
var gauge_row: HBoxContainer
var noise_name := label_of(&"BodySmall")
var gauge := ProgressBar.new()
var noise_label := label_of(&"BodySmall")
var alert_row: HBoxContainer
var alert_label := label_of(&"BodyMedium", AbyssColors.ERROR)
var weakness_label := label_of(&"BodyMedium", AbyssColors.SUCCESS)
var streak_row: HBoxContainer
var streak_label := label_of(&"BodySmall", AbyssColors.ERROR)


func _init(game_: Game) -> void:
	game = game_
	super()
	for short: Label in [noise_name, noise_label]:
		short.autowrap_mode = TextServer.AUTOWRAP_OFF
		short.size_flags_horizontal = Control.SIZE_SHRINK_END
	gauge.theme_type_variation = AbyssInputTheme.NOISE_GAUGE
	gauge.max_value = NoiseRules.THRESHOLD
	gauge.show_percentage = false
	gauge.custom_minimum_size.y = GAUGE_HEIGHT
	gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gauge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	gauge_row = add_row(&"graphic_eq", AbyssColors.WARNING, ICON_SIZE, [noise_name, gauge, noise_label])
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_child(alert_label)
	lines.add_child(weakness_label)
	alert_row = add_row(&"warning", AbyssColors.ERROR, ALERT_ICON_SIZE, [lines])
	streak_row = add_row(&"heart_broken", AbyssColors.ERROR, ICON_SIZE, [streak_label])
	refresh()


func refresh() -> void:
	# Called once by the base class, before the rows are built.
	if streak_row == null:
		return
	var state := game.human_player().raid_state
	var incoming := state.is_incoming()
	gauge_row.visible = not incoming
	alert_row.visible = incoming
	streak_row.visible = state.lost_in_a_row > 0
	noise_name.text = Texts.t(&"raidNoise")
	gauge.value = state.noise
	noise_label.text = "%d/%d" % [state.noise, NoiseRules.THRESHOLD]
	streak_label.text = Texts.t(&"raidLostInARow", {"lost": state.lost_in_a_row, "limit": DefeatChecker.LOST_RAIDS_LIMIT})
	if incoming:
		_tell_alert(state)


func _tell_alert(state: RaidState) -> void:
	var arrival: int = state.arrival_turn
	var wave := MonsterLairTexts.wave_label(state.incoming)
	alert_label.text = Texts.t(&"raidIncomingThisTurn", {"wave": wave}) if arrival <= game.turn \
			else Texts.t(&"raidIncomingOnTurn", {"turn": arrival, "wave": wave})
	var weakness: Variant = MonsterLairTexts.weakness_label(state.incoming)
	weakness_label.visible = weakness != null
	weakness_label.text = str(weakness) if weakness != null else ""
