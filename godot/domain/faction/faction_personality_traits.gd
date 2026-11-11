class_name FactionPersonalityTraits
extends RefCounted
## lib/domain/faction/faction_traits.dart, not in the Dart class: the traits
## of each personality, the private constants of FactionTraits, built anew at
## each call as a table of objects cannot be a constant.

const _U := UnitType.Value
const _B := BuildingType.Value
const _P := FactionPersonality.Value


static func of(personality: _P) -> FactionTraits:
	match personality:
		_P.WRECK_PILLAGERS:
			# Raiders: they pay for the race with what they take.
			return FactionTraits.new(4, 0.8, 2, {_U.HARPOONIST: 2, _U.SABOTEUR: 1}, 0.1, 0.5, true)
		_P.PEARL_ORDER:
			# A timer: economy and walls first, few and heavy attacks.
			return _grower(7, 0.85, {_U.GUARDIAN: 1, _U.DOME_BREAKER: 1}, 0.1, [
				_B.SOLAR_PANEL, _B.ALGAE_FARM, _B.CORAL_MINE, _B.ORE_EXTRACTOR,
				_B.HEADQUARTERS, _B.CORAL_CITADEL, _B.LABORATORY, _B.BARRACKS,
			])
		_P.ANGLER_CULT:
			# Holds posts: it takes the others' before their bases.
			return FactionTraits.new(
				4, 0.8, 3, {_U.GUARDIAN: 1, _U.HARPOONIST: 1}, 0.2, 0.5, true, true
			)
		_P.MURENA_HORDE:
			# Strikes first and early, then thins out: the mass eats the algae.
			return FactionTraits.new(3, 0.7, 2, {_U.HARPOONIST: 3}, 0.05, 0.5, true, false, 30, 0.2)
		_P.SIPHONOPHORE_GUILD:
			# Slow start, solid rampart, attacks only when sure.
			return _grower(9, 0.85, {_U.GUARDIAN: 1}, 0.08, [
				_B.SOLAR_PANEL, _B.ALGAE_FARM, _B.CORAL_MINE, _B.CORAL_CITADEL,
				_B.ORE_EXTRACTOR, _B.HEADQUARTERS, _B.LABORATORY, _B.BARRACKS,
			])
		_P.SILENCE_MONKS:
			# Unseen and small: rare strikes by a handful of saboteurs.
			return FactionTraits.new(9, 0.85, 3, {_U.SABOTEUR: 1}, 0.04)
		_P.CURRENT_NOMADS:
			# Gatherers: they roam, raise the Citadel last and hit the unguarded.
			return FactionTraits.new(
				5, 0.75, 3, {_U.HARPOONIST: 1}, 0.06, 0.65, true, false, 0, 0.0, false, 0.7, 3,
				[
					_B.HEADQUARTERS, _B.SOLAR_PANEL, _B.ALGAE_FARM, _B.CORAL_MINE,
					_B.ORE_EXTRACTOR, _B.BARRACKS, _B.LABORATORY, _B.CORAL_CITADEL,
				] as Array[BuildingType.Value]
			)
		_P.PYROSOME_HIVE:
			# Numbers: farms and barracks before anything.
			return _grower(6, 0.8, {_U.HARPOONIST: 1}, 0.12, [
				_B.ALGAE_FARM, _B.BARRACKS, _B.SOLAR_PANEL, _B.HEADQUARTERS,
				_B.CORAL_MINE, _B.ORE_EXTRACTOR, _B.LABORATORY, _B.CORAL_CITADEL,
			])
		_P.MAGMA_SMITHS:
			# Race down, over the posts of the others.
			return FactionTraits.new(
				6, 0.8, 3, {_U.GUARDIAN: 1, _U.DOME_BREAKER: 1}, 0.1, 0.65, true, true
			)
	# KRAKEN_FAITHFUL, the last case. Hold the kernel, and take it back from
	# whoever holds it.
	return FactionTraits.new(
		4, 0.85, 3, {_U.DOME_BREAKER: 1, _U.GUARDIAN: 1}, 0.1, 0.5, true, false, 0, 0.0, true, 0.8
	)


## Traits that change the defaults, the grudge aside, by their growth.
static func _grower(
	cadence: int,
	confidence: float,
	war_mix: Dictionary[UnitType.Value, int],
	war_share: float,
	growth: Array[BuildingType.Value],
) -> FactionTraits:
	return FactionTraits.new(
		cadence, confidence, 3, war_mix, war_share, 0.5, true, false, 0, 0.0, false, 0.5, 2, growth
	)
