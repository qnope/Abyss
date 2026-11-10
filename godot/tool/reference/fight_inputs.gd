class_name FightInputs
extends RefCounted
## Reads what a case of the fight vectors writes: a fighter, the runs of a
## side, an army and a boost (reference/vectors/README.md), as
## tool/vectors/domain/vector_inputs.dart writes them. VectorInputs writes a
## fighter back.


## `[typeKey, side, maxHp, atk, def, currentHp, isBoss]`.
static func combatant(written: Variant) -> Combatant:
	var fields: Array = written
	var side := VectorInputs.value(CombatSide.Value, fields[1]) as CombatSide.Value
	var key: String = fields[0]
	var max_hp: int = fields[2]
	var atk: int = fields[3]
	var def: int = fields[4]
	var current_hp: int = fields[5]
	var is_boss: bool = fields[6]
	return Combatant.new(side, key, max_hp, atk, def, current_hp, is_boss)


## A side as runs `[typeKey, side, maxHp, atk, def, isBoss, count]`: `count`
## fresh combatants each, in order.
static func runs(written: Variant) -> Array[Combatant]:
	var side: Array[Combatant] = []
	var all_runs: Array = written
	for run: Array in all_runs:
		var count: int = run[6]
		for _i: int in count:
			side.append(combatant([run[0], run[1], run[2], run[3], run[4], run[2], run[5]]))
	return side


## A side of fresh combatants as runs: each run of identical ones once, with
## its count, as `VectorInputs.runs` of Dart writes it.
static func runs_of(side: Array[Combatant]) -> Array:
	var written := []
	for c: Combatant in side:
		var run: Array = VectorInputs.combatant(c)
		run.remove_at(5)
		if not written.is_empty():
			var last: Array = written.back()
			if last.slice(0, 6) == run:
				var count: int = last[6]
				last[6] = count + 1
				continue
		run.append(1)
		written.append(run)
	return written


## `[[type, count], ...]` as an army whose entries keep that order.
static func army(pairs: Variant) -> Dictionary[UnitType.Value, int]:
	var units: Dictionary[UnitType.Value, int] = {}
	var all_pairs: Array = pairs
	for pair: Array in all_pairs:
		var count: int = pair[1]
		units[VectorInputs.value(UnitType.Value, pair[0]) as UnitType.Value] = count
	return units


## `[atkPercent, defPercent, hpPercent]`.
static func boost(percents: Variant) -> UnitBoost:
	var three: Array = percents
	var atk: int = three[0]
	var def: int = three[1]
	var hp: int = three[2]
	return UnitBoost.new(atk, def, hp)
