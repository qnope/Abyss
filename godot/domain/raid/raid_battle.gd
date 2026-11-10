class_name RaidBattle
extends RefCounted
## lib/domain/raid/raid_battle.dart: fights a raid wave with every unit
## standing on the base level, backed by the Coral Citadel rampart.

const BASE_LEVEL := 1


## A victory brings `loot_percent` % of a raid's loot; `surprise` marks an
## attack that is not a raid (see RaidReport). The fight, the wounded and
## the loot draw from `random` in that order, each from a die of its own
## when null.
static func fight(
	player: Player,
	wave: MonsterLair,
	turn: int,
	random: DartRandom = null,
	loot_percent := 100,
	surprise := false,
) -> RaidReport:
	var defenders := defenders_of(player)
	var rampart_level := CoralCitadelRampart.level_of(player.buildings)
	var rampart := CoralCitadelRampart.combatant_of(player.buildings)
	var player_side := CombatantBuilder.player_combatants_from(
		defenders, FightMonsterHelpers.unit_boost_of(player, false, true)
	)
	if rampart != null:
		player_side.append(rampart)
	var units := player.units_on_level(BASE_LEVEL)
	for type: UnitType.Value in defenders:
		units[type].count = 0
	var result := FightEngine.new(random).resolve(
		player_side, CombatantBuilder.monster_combatants_from(wave)
	)
	var breakdown := FightMonsterHelpers.resolve_casualties(player, BASE_LEVEL, result, random)
	var victory := result.is_victory()
	var tech := TechEffects.of(player)
	var loot: Dictionary[ResourceType.Value, int] = {}
	var pillaged: Dictionary[ResourceType.Value, int] = {}
	if victory:
		var won := RaidSpoils.cap_to_production(
			RaidSpoils.loot(wave.difficulty, random, loot_percent),
			ProductionCalculator.from_buildings(player.buildings, player.tech_branches),
		)
		loot = FightMonsterHelpers.apply_loot(player, tech.boost_loot(won))
	else:
		pillaged = RaidSpoils.pillage(player.resources, tech.pillage_rate())
	return RaidReport.new(
		turn, victory, wave, result, rampart_level, defenders, breakdown.survivors_intact,
		breakdown.wounded, breakdown.dead, loot, pillaged, surprise,
	)


## Units currently standing on the base level, by type.
static func defenders_of(player: Player) -> Dictionary[UnitType.Value, int]:
	var defenders: Dictionary[UnitType.Value, int] = {}
	var units := player.units_on_level(BASE_LEVEL)
	for type: UnitType.Value in units:
		if units[type].count > 0:
			defenders[type] = units[type].count
	return defenders
