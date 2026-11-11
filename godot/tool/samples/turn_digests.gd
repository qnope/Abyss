class_name TurnDigests
extends RefCounted
## What the digest test of the whole games (turn_digest_test.gd) compares
## with what a scratch Dart script printed: a game of GameFactory played by a
## script for the human, as ScriptRunner.runOn does, each turn ended by
## EndTurnAction (the factions playing first); after each turn, the moves,
## the TurnResult, the TurnEndEntry, the game and the next die, then the
## state of every player (TurnStates).


## Plays `script` for the human of `game` until `turns` or the end of the
## game, with the dice `Random(seed_)`. Two lines a turn.
static func play(game: Game, script: GameScript, seed_: int, turns: int) -> PackedStringArray:
	var random := DartRandom.new(seed_, false)
	var log: Array[ScriptLogEntry] = []
	var executor := ActionExecutor.new()
	var lines := PackedStringArray()
	while game.status == GameStatus.Value.PLAYING and game.turn <= turns:
		var from := log.size()
		var turn := ScriptTurn.new(game, random, log, null, executor)
		script.play_turn(turn)
		var moves := PackedStringArray()
		for entry: ScriptLogEntry in log.slice(from):
			moves.append(str(entry))
		if turn.is_over():
			lines.append("%d over %s %s" % [game.turn, _name(GameStatus.Value, game.status), ", ".join(moves)])
			break
		var human := game.human_player()
		var end: EndTurnActionResult = executor.execute(EndTurnAction.new(random), game, human)
		var last: TurnEndEntry = human.history_entries.back()
		var levi := "-" if game.leviathan_return == null else LeviathanDigests.state(game.leviathan_return)
		lines.append("%d %s # %s # e%d %s %s next %d" % [
			end.turn_result.previous_turn, ", ".join(moves), result(end.turn_result), last.turn,
			_name(GameStatus.Value, game.status), levi, random.next_int(1000),
		])
		var players := PackedStringArray()
		for p: Player in game.players.values():
			players.append("%s=%s" % [p.id, TurnStates.state(game, p)])
		lines.append("  " + " ; ".join(players))
	return lines


## The result of one end of turn.
static func result(r: TurnResult) -> String:
	var changes := PackedStringArray()
	for c: TurnResourceChange in r.changes:
		changes.append("%s:%d-%d%s=%d>%d" % [
			_name(ResourceType.Value, c.type), c.produced, c.consumed, "C" if c.was_capped else "",
			c.before_amount, c.after_amount,
		])
	var deactivated := PackedStringArray()
	for b: BuildingType.Value in r.deactivated_buildings:
		deactivated.append(_name(BuildingType.Value, b))
	var explorations := PackedStringArray()
	for e: ExplorationResult in r.explorations:
		var notable := PackedStringArray()
		for c: CellContentType.Value in e.notable_content:
			notable.append(_name(CellContentType.Value, c))
		explorations.append("%d,%d:%d:%s" % [e.target.x, e.target.y, e.new_cells_revealed, "+".join(notable)])
	var arrived := PackedStringArray()
	for o: ReinforcementOrder in r.arrived_reinforcements:
		arrived.append("%d>%d@%d:%s" % [o.from_level, o.to_level, o.depart_turn, TurnStates.units(o.units)])
	var objectives := PackedStringArray()
	for o: ObjectiveCompletion in r.objectives:
		objectives.append("%s:%s" % [
			_name(ObjectiveId.Value, o.objective.id), HistoryDigests.counts(o.credited, ResourceType.Value)
		])
	var temporary := PackedStringArray()
	for o: TemporaryObjectiveEnd in r.temporary_objectives:
		temporary.append("%s:%d:%s" % [
			_name(TemporaryObjectiveKind.Value, o.objective.kind), o.objective.last_turn,
			_name(TemporaryObjectiveOutcome.Value, o.outcome),
		])
	var attacks := PackedStringArray()
	for a: FactionAttackReport in r.attacks:
		attacks.append(LeviathanDigests.report(a))
	return "%d>%d %s [%s] d[%s] l[%s] x[%s] r[%s] raid[%s %s %s] v[%s %s] e[%s %s %s] o[%s] t[%s] a[%s] lv[%s] al[%s]" % [
		r.previous_turn, r.new_turn, r.had_recruited_units, ",".join(changes), ",".join(deactivated),
		TurnStates.units(r.lost_units), ",".join(explorations), ",".join(arrived), raid(r.raid),
		TurnStates.wave(r.announced_raid), WarDigests.text(r.announced_raid_turn), _volcano(r.volcano),
		TurnStates.wave(r.announced_wave), _event(r.event), _event(r.defaulted_event), raid(r.predators),
		",".join(objectives), ",".join(temporary), " ; ".join(attacks), LeviathanDigests.report(r.leviathan),
		LeviathanDigests.announced(r.announced_leviathan),
	]


## RaidDigests.report, `S` after it for a surprise, or `-`.
static func raid(r: RaidReport) -> String:
	if r == null:
		return "-"
	return RaidDigests.report(r) + ("S" if r.surprise else "")


static func _volcano(r: VolcanoReport) -> String:
	return "-" if r == null else RaidDigests.volcano_report(r)


static func _event(type: Variant) -> String:
	if type == null:
		return "null"
	var event: RandomEventType.Value = type
	return _name(RandomEventType.Value, event)


static func _name(enumeration: Dictionary, value: int) -> String:
	return DartEnum.name_of(enumeration, value)
