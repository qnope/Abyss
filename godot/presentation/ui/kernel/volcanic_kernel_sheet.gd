class_name VolcanicKernelSheet
extends MapSheet
## What a touch on the volcano opens (lib/presentation/widgets/map/
## volcanic_kernel_sheet.dart): while the kraken guards it, its description
## and the button that launches the assault (above it, the plan of the assault
## when `../assault/AssaultPlans` gives one); once the player holds it, its garrison and the
## buttons that move units in and out ([KernelGarrisonPanel]), the one that
## fills the garrison surrounded by the guide's halo when the tutorial asks.
##
## The sheet only tells what the player wants: the signals come after it
## closed, for its owner to open the army to assault with or the picker.

## The player wants to assault the kernel.
signal attack_requested
## The player wants to put units in the garrison.
signal garrison_requested
## The player wants to take units out of the garrison.
signal withdraw_requested

const PICTURE_SIZE := 64.0

var is_captured: bool
var description_label: Label
var attack_button: Button
var garrison_panel: KernelGarrisonPanel


## The sheet of the kernel for the human of [param game]; [param captured]
## says whether the human holds it, [param plan] is the plan of an assault.
func _init(game: Game, captured: bool, plan: Control = null) -> void:
	is_captured = captured
	super(Portrait.new(BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL), PICTURE_SIZE,
		AbyssColors.CORAL_PINK), func() -> String: return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL))
	description_label = label(func() -> String: return Texts.t(&"mapKernelCaptured" if captured else &"mapKernelUncaptured"))
	description_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	column.add_child(description_label)
	column.add_child(HSeparator.new())
	if captured:
		var advice := GuideAdvisor.of(game, game.human_player())
		garrison_panel = KernelGarrisonPanel.new(game.human_player(), advice != null and advice.target.garrison)
		garrison_panel.garrison_requested.connect(_then.bind(garrison_requested))
		garrison_panel.withdraw_requested.connect(_then.bind(withdraw_requested))
		column.add_child(garrison_panel)
		return
	if plan != null:
		column.add_child(plan)
	attack_button = button(func() -> String: return Texts.t(&"fightLaunchAssault"))
	attack_button.pressed.connect(_then.bind(attack_requested))
	column.add_child(attack_button)


## Closes the sheet, then tells [param asked].
func _then(asked: Signal) -> void:
	close()
	asked.emit()
