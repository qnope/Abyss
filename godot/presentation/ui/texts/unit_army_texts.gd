class_name UnitArmyTexts
extends RefCounted
## lib/presentation/extensions/unit_army_texts.dart (UnitArmyTexts): the texts
## of a squad on the army's parade ground, in the language on.


## The name on the plaque of a squad of [param count] units: in the singular
## for one unit or a [param locked] squad ("Gardien"), in the plural for any
## other count, none included ("Briseurs").
static func plaque_name(type: UnitType.Value, count: int, locked := false) -> String:
	if locked or count == 1:
		return UnitTexts.display_name(type)
	return _plural(type)


## What a screen reader says of the squad: its name and how many units it
## holds, whether it can recruit this turn; or that it is [param locked] and
## the barracks level it waits for.
static func army_label(type: UnitType.Value, count: int, locked: bool, recruitable: bool) -> String:
	var parts := PackedStringArray([plaque_name(type, count, locked)])
	if locked:
		parts.append(Texts.t(&"armyUnitLocked", {"level": UnitCostCalculator.new().unlock_level(type)}))
	else:
		parts.append(Texts.t(&"unitTotalCount", {"count": count}))
		if recruitable:
			parts.append(Texts.t(&"armyUnitRecruitable"))
	return ", ".join(parts)


## The pill of a locked squad: the barracks level it waits for.
static func lock_pill(type: UnitType.Value) -> String:
	return Texts.t(&"armyLockPill", {"level": UnitCostCalculator.new().unlock_level(type)})


## The plural of the type's name, capitalised: the count of two units
## ("2 harponneurs") without its number.
static func _plural(type: UnitType.Value) -> String:
	var name := UnitTexts.units(type, 2).lstrip("0123456789 \t")
	return name.left(1).to_upper() + name.substr(1)
