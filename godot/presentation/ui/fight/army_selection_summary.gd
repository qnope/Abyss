class_name ArmySelectionSummary
extends RefCounted
## What the card under an army selection adds up
## (lib/presentation/screens/game/fight/army_selection_summary.dart): the
## boost the units on the attack fight with and the attack and defence of the
## ones picked. It uses the same [UnitBoost] as the domain's
## `CombatantBuilder`, so the totals shown are the stats the units fight with.


## The boost of the units on the attack, as every selection sends them.
static func boost_of(player: Player) -> UnitBoost:
	return TechEffects.of(player).unit_boost(true)


## The attack of the units [param selected] (counts by type), boosted.
static func total_atk(selected: Dictionary[UnitType.Value, int], boost: UnitBoost) -> int:
	return _total(selected, func(stats: UnitStats) -> int: return boost.atk(stats.atk))


## The defence of the units [param selected] (counts by type), boosted.
static func total_def(selected: Dictionary[UnitType.Value, int], boost: UnitBoost) -> int:
	return _total(selected, func(stats: UnitStats) -> int: return boost.def(stats.def))


static func _total(selected: Dictionary[UnitType.Value, int], stat: Callable) -> int:
	var sum := 0
	for type: UnitType.Value in selected:
		if selected[type] > 0:
			var each: int = stat.call(UnitStats.for_type(type))
			sum += each * selected[type]
	return sum
