class_name AssaultDamageCard
extends AssaultLineCard
## What a won assault broke in the base: the rampart, or the headquarters when
## there was none (lib/presentation/widgets/fight/assault_damage_card.dart).
## Says the base held when nothing broke.


func _init(entry: BaseAssaultEntry) -> void:
	var sources: Array[Callable] = []
	if entry.rampart_after != entry.rampart_before:
		sources.append(Texts.t.bind(&"assaultRampart", {"before": entry.rampart_before, "after": entry.rampart_after}))
	if entry.headquarters_after != entry.headquarters_before:
		sources.append(Texts.t.bind(&"assaultHeadquarters",
			{"before": entry.headquarters_before, "after": entry.headquarters_after}))
	if sources.is_empty():
		sources.append(Texts.t.bind(&"assaultBaseIntact"))
	super(sources)
