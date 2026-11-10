class_name BaseRaze
extends RefCounted
## lib/domain/action/base_damage.dart, `BaseRaze`: the price of a lost base:
## the rampart falls by RAMPART_LEVELS levels, or the headquarters by one
## when there is none, and the attacker pillages `RaidSpoils.PILLAGE_RATE`
## of the stocks.

const RAMPART_LEVELS := 2


static func apply(attacker: Player, target: Player) -> BaseDamage:
	var before := BaseDamage.none(target)
	var rampart := before.rampart_before
	var hq := before.headquarters_before
	if rampart > 0:
		rampart = clampi(rampart - RAMPART_LEVELS, 0, rampart)
		target.buildings[BuildingType.Value.CORAL_CITADEL].level = rampart
	else:
		hq = target.lower_headquarters(1)
	var pillaged := RaidSpoils.pillage(target.resources)
	return BaseDamage.new(
		before.rampart_before, rampart, before.headquarters_before, hq,
		pillaged, ResourceCredit.add(attacker.resources, pillaged),
	)
