class_name RampartTexts
extends RefCounted
## lib/presentation/extensions/rampart_texts.dart: short statistics of the
## ramparts, such as "120 PV, DEF 7", in the language on.


## The rampart of a Coral Citadel at [param level], "none" when unbuilt.
static func coral(level: int) -> String:
	if level <= 0:
		return Texts.t(&"baseRampartNone")
	return Texts.t(&"baseCoralRampartStats", {
		"hp": CoralCitadelRampart.hp_for_level(level),
		"def": CoralCitadelRampart.def_for_level(level),
	})


## The magma rampart of a volcanic kernel at [param level].
static func magma(level: int) -> String:
	return Texts.t(&"baseMagmaRampartStats", {
		"hp": MagmaRampart.hp_for_level(level),
		"atk": MagmaRampart.atk_for_level(level),
		"def": MagmaRampart.def_for_level(level),
	})
