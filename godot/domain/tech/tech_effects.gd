class_name TechEffects
extends RefCounted
## lib/domain/tech/tech_effects.dart: everything a player's research changes
## in the rules, read from the tiers and options of the three branches. Its
## factory `of`, which reads a Player, comes with the game module.

## Bonus of each shared tier of a branch, in percent.
const TIER_PERCENT := 20
const _MILITARY := TechBranch.Value.MILITARY

## The perks taken in the branches, a set.
var perks: Dictionary[TechPerk.Value, bool]
## The laboratory is degraded: every effect of the research is halved.
var halved: bool
var _tiers: Dictionary[TechBranch.Value, int]


func _init(
	tech_branches: Dictionary[TechBranch.Value, TechBranchState], halved_ := false
) -> void:
	halved = halved_
	for branch: TechBranch.Value in tech_branches:
		_tiers[branch] = tech_branches[branch].tiers()
		perks.merge(tech_branches[branch].perks())


func tiers_of(branch: TechBranch.Value) -> int:
	return _tiers.get(branch, 0)


func has(perk: TechPerk.Value) -> bool:
	return perks.has(perk)


## ATK bonus of every unit, in percent, plus Assaut on offence.
func atk_percent(attacking := false) -> int:
	return _half(
		tiers_of(_MILITARY) * TIER_PERCENT
		+ (35 if has(TechPerk.Value.CORAL_BLADES) else 0)
		+ (35 if attacking and has(TechPerk.Value.DEEP_ASSAULT) else 0)
	)


## DEF bonus of every unit, in percent, plus Rempart on the base.
func def_percent(defending_base := false) -> int:
	return _half(
		tiers_of(_MILITARY) * TIER_PERCENT
		+ (35 if defending_base and has(TechPerk.Value.LIVING_RAMPART) else 0)
	)


func hp_percent() -> int:
	return _half(35 if has(TechPerk.Value.NACRE_SHELL) else 0)


## Stat boosts of the units, on offence or guarding the base.
func unit_boost(attacking := false, defending_base := false) -> UnitBoost:
	return UnitBoost.new(atk_percent(attacking), def_percent(defending_base), hp_percent())


## Production bonus on `type`, in percent.
func production_percent(type: ResourceType.Value) -> int:
	var farming := type == ResourceType.Value.ALGAE or type == ResourceType.Value.CORAL
	var drilling := type == ResourceType.Value.ORE or type == ResourceType.Value.ENERGY
	return _half(
		tiers_of(TechBranch.Value.RESOURCES) * TIER_PERCENT
		+ (35 if farming and has(TechPerk.Value.INTENSIVE_FARMING) else 0)
		+ (35 if drilling and has(TechPerk.Value.DEEP_DRILLING) else 0)
	)


## Share of the stocks a lost raid carries away.
func pillage_rate() -> float:
	return (0.225 if halved else 0.15) if has(TechPerk.Value.SEALED_CHESTS) else 0.3


## Discount on building upgrades, in percent.
func upgrade_discount_percent() -> int:
	return _half(15 if has(TechPerk.Value.THRIFTY_WORKSITES) else 0)


## Side of the square an exploration reveals.
func reveal_side() -> int:
	var bonus := (
		2 * tiers_of(TechBranch.Value.EXPLORER) + (2 if has(TechPerk.Value.DEEP_SONAR) else 0)
	)
	return 3 + (DartMath.trunc_div(bonus, 4) * 2 if halved else bonus)


## Noise an exploration or a fight really makes: none once silent.
func muffle(noise: int) -> int:
	if not has(TechPerk.Value.SILENT_SWIM):
		return noise
	return DartMath.trunc_div(noise, 2) if halved else 0


## Loot multiplier, in percent, of lairs, ruins and transition bases.
func loot_percent() -> int:
	return 100 + _half(50 if has(TechPerk.Value.WRECK_RAIDERS) else 0)


## Turns between a raid announcement and its arrival.
func raid_warning_turns() -> int:
	return (3 if halved else 4) if has(TechPerk.Value.SENTINELS) else 2


## Scales every amount of `loot` by loot_percent(), in a new map.
func boost_loot(loot: Dictionary[ResourceType.Value, int]) -> Dictionary[ResourceType.Value, int]:
	var boosted: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in loot:
		boosted[type] = DartMath.trunc_div(loot[type] * loot_percent(), 100)
	return boosted


func _half(bonus: int) -> int:
	return BuildingDegradation.half(bonus, halved)
