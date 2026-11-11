class_name VolcanoDueWarning
extends DueWarning
## The warning when a kraken wave hits the kernel at the end of this turn and
## no unit guards it (lib/presentation/widgets/volcano/
## volcano_due_warning.dart).

var wave: MonsterLair


func _init(wave_: MonsterLair) -> void:
	wave = wave_
	super(&"volcano", func() -> String:
		return Texts.t(&"volcanoDueWarning", {"wave": MonsterLairTexts.wave_label(wave_)}))
