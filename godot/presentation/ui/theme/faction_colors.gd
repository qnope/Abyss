class_name FactionColors
## The colour of each faction: on the map, in the ranking. Ten hues far
## from each other and from the cyan of the human's posts. Ported from
## lib/presentation/theme/faction_colors.dart, one constant per
## FactionPersonality, named after it.

const WRECK_PILLAGERS := Color("ff7043")
const PEARL_ORDER := Color("f5f5f5")
const ANGLER_CULT := Color("b388ff")
const MURENA_HORDE := Color("66bb6a")
const SIPHONOPHORE_GUILD := Color("ff80ab")
const SILENCE_MONKS := Color("90a4ae")
const CURRENT_NOMADS := Color("ffd740")
const PYROSOME_HIVE := Color("26a69a")
const MAGMA_SMITHS := Color("e53935")
const KRAKEN_FAITHFUL := Color("5c6bc0")


## The colour of the faction of [param personality].
static func of(personality: FactionPersonality.Value) -> Color:
	match personality:
		FactionPersonality.Value.WRECK_PILLAGERS:
			return WRECK_PILLAGERS
		FactionPersonality.Value.PEARL_ORDER:
			return PEARL_ORDER
		FactionPersonality.Value.ANGLER_CULT:
			return ANGLER_CULT
		FactionPersonality.Value.MURENA_HORDE:
			return MURENA_HORDE
		FactionPersonality.Value.SIPHONOPHORE_GUILD:
			return SIPHONOPHORE_GUILD
		FactionPersonality.Value.SILENCE_MONKS:
			return SILENCE_MONKS
		FactionPersonality.Value.CURRENT_NOMADS:
			return CURRENT_NOMADS
		FactionPersonality.Value.PYROSOME_HIVE:
			return PYROSOME_HIVE
		FactionPersonality.Value.MAGMA_SMITHS:
			return MAGMA_SMITHS
	return KRAKEN_FAITHFUL
