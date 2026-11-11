class_name AssaultKernelCard
extends AssaultLineCard
## What a won assault did to a volcanic kernel (lib/presentation/widgets/fight/
## assault_kernel_card.dart): the level it lost, and who holds it now when the
## last level fell. The entry carries the kernel's levels in its rampart fields.


func _init(entry: BaseAssaultEntry) -> void:
	var sources: Array[Callable] = [
		Texts.t.bind(&"assaultKernelLevel", {"before": entry.rampart_before, "after": entry.rampart_after}),
	]
	if entry.rampart_after == 0:
		sources.append(Texts.t.bind(&"assaultKernelLost" if entry.defending else &"assaultKernelTaken"))
	super(sources)
