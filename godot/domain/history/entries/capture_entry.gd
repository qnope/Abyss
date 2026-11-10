class_name CaptureEntry
extends HistoryEntry
## lib/domain/history/entries/capture_entry.dart: history entry recording the
## capture of a transition base, or of the volcanic kernel; or a victory
## there that captured nothing, the Abyss Admiral fallen (`captured` false).
## Carries the whole FightResult, as CombatEntry. Without the `title` and
## `subtitle` of the Dart class, which only keep the layout of old saves.

## The `transition_base_name` of the capture of the volcanic kernel.
const VOLCANIC_KERNEL := "volcanicKernel"
## The `transition_base_name` older saves stored for the kernel capture.
const LEGACY_VOLCANIC_KERNEL := "Noyau Volcanique"

var transition_base_name: String
var fight_result: FightResult
## Whether the base was taken: false when the assault was won but every
## Abyss Admiral fell.
var captured: bool


func _init(
	turn_: int, transition_base_name_: String, fight_result_: FightResult, captured_ := true
) -> void:
	super(turn_, HistoryEntryCategory.Value.CAPTURE)
	transition_base_name = transition_base_name_
	fight_result = fight_result_
	captured = captured_


## Whether the volcanic kernel was captured rather than a transition base.
func is_volcanic_kernel() -> bool:
	return (
		transition_base_name == VOLCANIC_KERNEL
		or transition_base_name == LEGACY_VOLCANIC_KERNEL
	)
