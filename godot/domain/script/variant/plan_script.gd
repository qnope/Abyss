class_name PlanScript
extends GameScript
## lib/domain/script/variant/plan_script.dart: plays the plan of an exported
## replay again, moved away from the original game as `variant` says:
## another map, other dice, a smaller army, later turns.
##
## Unlike the exact replay, it plays on after the replay's last turn until
## the game ends, tries a failed step again on each later turn for
## `variant.patience` turns as a player sticking to a plan would (the steps
## on the road to the volcano wait as long as it takes), and lets the bot
## rules answer the events of the turns with no recorded choice.

var variant: ReplayVariant
## The name of the replay's player.
var player: String
## The map seed of the replay (an int), or null.
var replay_map_seed: Variant
var end_turn_seeds: Dictionary[int, int]

var _name: String
var _pending: Array[PlanStep]
## Whether the variant's delays are still to be drawn (game dice, turn 1).
var _undrawn: bool


func _init(
	name_: String, variant_: ReplayVariant, player_: String, replay_map_seed_: Variant,
	end_turn_seeds_: Dictionary[int, int], steps: Array[PlanStep], undrawn: bool,
) -> void:
	_name = name_
	variant = variant_
	player = player_
	replay_map_seed = replay_map_seed_
	end_turn_seeds = end_turn_seeds_
	_pending = steps
	_undrawn = undrawn


## `PlanScript.fromReplay`: reads an exported replay; `random` draws the
## delays of `variant`, or the game's dice on the first turn when null.
## `name_` (a String) names the script, null for the replay's.
static func from_replay(
	source: String, variant_: ReplayVariant, random: DartRandom = null, name_: Variant = null,
) -> PlanScript:
	var json: Dictionary = ReplayJournal.whole_numbers(JSON.parse_string(source))
	var turns: Dictionary = json["turns"]
	var order: Array[int] = []
	for key: String in turns:
		order.append(key.to_int())
	order.sort()
	var steps: Array[PlanStep] = []
	for t: int in order:
		var due := roundi(t * variant_.stretch)
		if variant_.jitter > 0 and random != null:
			due += random.next_int(variant_.jitter + 1)
		for action: Dictionary in turns[str(t)]:
			steps.append(PlanStep.new(due, steps.size(), action.duplicate()))
	var seeds: Dictionary[int, int] = {}
	if json.get("endTurnSeeds") is Dictionary:
		var recorded: Dictionary = json["endTurnSeeds"]
		for key: Variant in recorded:
			seeds[str(key).to_int()] = recorded[key]
	var replay_name: Variant = json.get("name")
	var label := "%s (%s)" % [replay_name if replay_name != null else "replay", variant_.label()]
	var player_: Variant = json.get("player")
	return PlanScript.new(
		label if name_ == null else str(name_), variant_, str(player_) if player_ != null else "replay",
		json.get("mapSeed"), seeds, steps, random == null and variant_.jitter > 0,
	)


func name() -> String:
	return _name


func player_name() -> String:
	return player


func map_seed() -> Variant:
	return replay_map_seed if variant.same_map else null


func end_turn_random(turn: int) -> DartRandom:
	var pinned := variant.same_map and variant.same_dice
	return DartRandom.new(end_turn_seeds[turn]) if pinned and end_turn_seeds.has(turn) else null


## Steps not played yet, in the order of the original game.
func pending() -> Array[PlanStep]:
	return _pending.duplicate()


func play_turn(turn: ScriptTurn) -> void:
	if _undrawn:
		_draw(turn.random())
	var due := _pending.filter(func(s: PlanStep) -> bool: return s.turn <= turn.number())
	DartSort.sort(due, func(a: PlanStep, b: PlanStep) -> int: return DartSort.compare_ints(a.rank, b.rank))
	if not variant.is_exact():
		var choose := not due.any(func(s: PlanStep) -> bool: return s.verb() == "event")
		EventMoves.play_events(turn, ArmyPlanner.new(), choose)
	if variant.defends and turn.player.raid_state.is_incoming():
		BattleMoves.defend_base(turn, ArmyPlanner.new())
	if variant.defends:
		BattleMoves.defend_attacks(turn, ArmyPlanner.new())
	for step: PlanStep in due:
		if turn.is_over():
			return
		var done := PlanMoves.play_step(turn, step, variant)
		var late := turn.number() - step.turn >= variant.patience
		if done or late and not step.persistent():
			_pending.erase(step)
	if variant.defends and not turn.is_over():
		KernelGuardMoves.guard_kernel(turn, ArmyPlanner.new())
		LeviathanGuardMoves.guard_faille(turn)


func _draw(random: DartRandom) -> void:
	_undrawn = false
	var delays: Dictionary[int, int] = {}
	var drawn: Array[PlanStep] = []
	for s: PlanStep in _pending:
		if not delays.has(s.turn):
			delays[s.turn] = random.next_int(variant.jitter + 1)
		drawn.append(PlanStep.new(s.turn + delays[s.turn], s.rank, s.json))
	_pending = drawn
