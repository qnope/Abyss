class_name StrikeLead
extends RefCounted
## The unit that leads an army sent to fight (lib/presentation/widgets/map/
## effects/strike/strike_lead.dart): the one whose figure stands for the whole
## army, and the figures that show it on the map.

## The most figures of an army shown.
const MAX_FIGURES := 3


## The unit type leading the army [param sent] (a UnitType.Value, or null for an
## empty army): the type sent in the largest number; between types sent as many,
## the stronger attacker, then the first type.
static func of(sent: Dictionary[UnitType.Value, int]) -> Variant:
	var lead: Variant = null
	for type: UnitType.Value in UnitType.Value.values():
		var count: int = sent.get(type, 0)
		if count <= 0:
			continue
		if lead == null:
			lead = type
			continue
		var held: UnitType.Value = lead
		if _leads(type, count, held, sent[held]):
			lead = type
	return lead


## The figures that stand for the army [param sent], the lead's first: as many as
## [SquadSize] gives for its size, up to [constant MAX_FIGURES], told by the
## types sent, the largest number first (the lead), each type once before any
## twice.
static func figures(sent: Dictionary[UnitType.Value, int]) -> Array[UnitType.Value]:
	var found: Array[UnitType.Value] = []
	var total := 0
	var types: Array[UnitType.Value] = []
	var lead: Variant = of(sent)
	if lead == null:
		return found
	types.append(lead)
	for type: UnitType.Value in UnitType.Value.values():
		var count: int = sent.get(type, 0)
		total += maxi(count, 0)
		if count > 0 and not types.has(type):
			types.append(type)
	for index in mini(SquadSize.of(total), MAX_FIGURES):
		found.append(types[index % types.size()])
	return found


## Whether [param type], sent [param count] times, leads before [param other],
## sent [param other_count] times and listed before it.
static func _leads(type: UnitType.Value, count: int, other: UnitType.Value, other_count: int) -> bool:
	if count != other_count:
		return count > other_count
	return UnitStats.for_type(type).atk > UnitStats.for_type(other).atk
