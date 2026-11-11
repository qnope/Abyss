class_name VolcanoStatusBar
extends ThreatStrip
## The strip under the raid bar once the kraken waves have started: the wave
## due at the end of the turn against the kernel's garrison, red when nobody
## guards the kernel (lib/presentation/widgets/volcano/volcano_status_bar.dart).
## It hides itself while no wave is announced.

const ICON_SIZE := 16.0

var game: Game
var label := label_of(&"BodySmall", AbyssColors.CORAL_PINK)
var row: HBoxContainer


func _init(game_: Game) -> void:
	game = game_
	super()
	row = add_row(&"volcano", AbyssColors.CORAL_PINK, ICON_SIZE, [label])
	refresh()


func refresh() -> void:
	# Called once by the base class, before the row is built.
	if row == null:
		return
	var player := game.human_player()
	var state := player.volcano_state
	visible = state.is_incoming()
	if not visible:
		return
	var size := KernelGarrison.size_of(player)
	label.add_theme_color_override(&"font_color", AbyssColors.ERROR if size == 0 else AbyssColors.CORAL_PINK)
	label.text = Texts.t(&"volcanoStatus", {
		"level": KernelGarrison.kernel_level_of(player),
		"wave": MonsterLairTexts.wave_label(state.incoming),
		"size": size,
	})
