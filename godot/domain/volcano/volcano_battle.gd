class_name VolcanoBattle
extends RefCounted
## lib/domain/volcano/volcano_battle.dart: fights a kraken wave with the
## kernel's garrison, backed by the magma rampart. A won wave takes one
## level off the kernel.


## The fight and the wounded draw from `random` in that order, each from a
## die of its own when null.
static func fight(player: Player, wave: MonsterLair, turn: int, random: DartRandom = null) -> VolcanoReport:
	var defenders := KernelGarrison.of(player)
	var kernel_level := KernelGarrison.kernel_level_of(player)
	var rampart := MagmaRampart.combatant_for(kernel_level)
	var player_side := CombatantBuilder.player_combatants_from(
		defenders, FightMonsterHelpers.unit_boost_of(player, false, true)
	)
	if rampart != null:
		player_side.append(rampart)
	var stock := KernelGarrison.stock_of(player)
	for type: UnitType.Value in defenders:
		stock[type].count = 0
	var result := FightEngine.new(random).resolve(
		player_side, CombatantBuilder.monster_combatants_from(wave)
	)
	var breakdown := FightMonsterHelpers.resolve_casualties(
		player, KernelGarrison.STOCK_KEY, result, random
	)
	if not result.is_victory() and kernel_level > 0:
		player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = kernel_level - 1
	return VolcanoReport.new(
		turn, result.is_victory(), wave, result, kernel_level, defenders,
		breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
	)
