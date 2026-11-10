class_name FactionPersonality
extends RefCounted
## lib/domain/faction/faction_personality.dart: the ten ways a faction goes
## after the volcanic kernel.

enum Value {
	WRECK_PILLAGERS,
	PEARL_ORDER,
	ANGLER_CULT,
	MURENA_HORDE,
	SIPHONOPHORE_GUILD,
	SILENCE_MONKS,
	CURRENT_NOMADS,
	PYROSOME_HIVE,
	MAGMA_SMITHS,
	KRAKEN_FAITHFUL,
}

const _LABELS: Dictionary[Value, String] = {
	Value.WRECK_PILLAGERS: "Les Pillards de l'Épave",
	Value.PEARL_ORDER: "L'Ordre de Nacre",
	Value.ANGLER_CULT: "Le Culte de la Baudroie",
	Value.MURENA_HORDE: "La Horde des Murènes",
	Value.SIPHONOPHORE_GUILD: "La Guilde des Siphonophores",
	Value.SILENCE_MONKS: "Les Moines du Silence",
	Value.CURRENT_NOMADS: "Les Nomades du Courant",
	Value.PYROSOME_HIVE: "La Ruche des Pyrosomes",
	Value.MAGMA_SMITHS: "Les Forgerons du Magma",
	Value.KRAKEN_FAITHFUL: "Les Fidèles du Kraken",
}


## Name of the faction, in French like the rest of the domain texts.
static func label(personality: Value) -> String:
	return _LABELS[personality]
