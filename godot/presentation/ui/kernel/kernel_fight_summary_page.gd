class_name KernelFightSummaryPage
extends AssaultSummaryPage
## The report of the assault on the volcano the kraken guards
## (lib/presentation/screens/game/fight/kernel_fight_summary_screen.dart):
## "Assault: Volcanic Kernel", and "kernel captured" when it was taken.

var result: AttackVolcanicKernelResult
var target_x: int
var target_y: int


## The report of [param result_], of the assault on the cell ([param x],
## [param y]).
func _init(result_: AttackVolcanicKernelResult, x: int, y: int) -> void:
	result = result_
	target_x = x
	target_y = y
	super(func() -> String: return Texts.t(&"fightAssaultOn", {"target": BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL)}),
		&"fightKernelCaptured", result_.victory, result_.captured, result_.fight, result_.sent,
		result_.survivors_intact, result_.wounded, result_.dead)
