class_name KernelGarrisonPanel
extends SheetSection
## The part of the kernel's sheet once it is captured (lib/presentation/
## widgets/volcano/kernel_garrison_panel.dart): its level, the magma rampart,
## the garrison and the units waiting outside it, the next kraken wave, and
## the buttons that move units in and out of the garrison. The guide's halo
## surrounds the one that fills the garrison when [param guided].
##
## It only tells what the player wants: the units move through its owner.

## The player wants to put units in the garrison.
signal garrison_requested
## The player wants to take units out of the garrison.
signal withdraw_requested

const BUTTON_GAP := 8
const HALO_RADIUS := 20

var player: Player
var garrison_button: Button
var withdraw_button: Button
var halo: GuideHalo


func _init(player_: Player, guided := false) -> void:
	player = player_
	super()
	var state := player.volcano_state
	var level := KernelGarrison.kernel_level_of(player)
	var outside := 0
	for unit: Unit in player.units_on_level(KernelGarrison.VOLCANO_LEVEL).values():
		outside += unit.count
	column.add_child(label(func() -> String: return Texts.t(&"volcanoKernelLevel",
		{"level": KernelGarrison.kernel_level_of(player)})))
	if level > 0:
		column.add_child(label(func() -> String: return Texts.t(&"volcanoMagmaRampart",
			{"stats": RampartTexts.magma(KernelGarrison.kernel_level_of(player))}), &"", AbyssColors.CORAL_PINK))
	column.add_child(swap(func() -> Control: return UnitCountPanel.new(Texts.t(&"volcanoGarrisonTitle"),
		KernelGarrison.of(player), Texts.t(&"volcanoGarrisonEmpty"))))
	if outside > 0:
		column.add_child(label(func() -> String: return Texts.t(&"volcanoOutsideGarrison",
			{"count": outside, "level": KernelGarrison.VOLCANO_LEVEL}), &"", AbyssColors.ON_SURFACE_DIM))
	if state.incoming != null:
		column.add_child(label(func() -> String: return Texts.t(&"volcanoNextWave",
			{"wave": MonsterLairTexts.wave_label(state.incoming)}), &"", AbyssColors.ERROR))
	if state.levels_lost > 0:
		column.add_child(label(func() -> String: return Texts.t(&"volcanoLevelsLost",
			{"count": state.levels_lost}), &"", AbyssColors.ON_SURFACE_DIM))
	garrison_button = button(func() -> String: return Texts.t(&"volcanoGarrisonUnits"))
	garrison_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	garrison_button.pressed.connect(garrison_requested.emit)
	halo = GuideHalo.new(garrison_button, guided, HALO_RADIUS)
	halo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	withdraw_button = button(func() -> String: return Texts.t(&"volcanoWithdraw"))
	withdraw_button.theme_type_variation = &"OutlinedButton"
	withdraw_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	withdraw_button.disabled = KernelGarrison.size_of(player) <= 0
	withdraw_button.pressed.connect(withdraw_requested.emit)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", BUTTON_GAP)
	buttons.add_child(halo)
	buttons.add_child(withdraw_button)
	column.add_child(buttons)
