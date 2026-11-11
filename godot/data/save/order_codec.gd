class_name OrderCodec
extends RefCounted
## The orders a player gives that play out at the end of the turn, in a
## save: the explorations and the reinforcements on their way.


static func exploration(x: ExplorationOrder) -> Dictionary:
	return {"target": MapCodec.position(x.target), "level": x.level}


static func read_exploration(r: SaveReader, value: Variant) -> ExplorationOrder:
	var m := r.object(value, "ExplorationOrder")
	return ExplorationOrder.new(MapCodec.read_position(r, r.at(m, "target")), r.int_at(m, "level"))


static func reinforcement(x: ReinforcementOrder) -> Dictionary:
	return {
		"fromLevel": x.from_level, "toLevel": x.to_level, "units": SaveValues.counts(x.units, UnitType.Value),
		"departTurn": x.depart_turn, "arrivalPoint": MapCodec.position(x.arrival_point),
	}


static func read_reinforcement(r: SaveReader, value: Variant) -> ReinforcementOrder:
	var m := r.object(value, "ReinforcementOrder")
	return ReinforcementOrder.new(
		r.int_at(m, "fromLevel"), r.int_at(m, "toLevel"), SaveCollections.counts_at(r, m, "units", UnitType.Value),
		r.int_at(m, "departTurn"), MapCodec.read_position(r, r.at(m, "arrivalPoint")),
	)
