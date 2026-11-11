class_name FactionTurn
extends ScriptTurn
## lib/domain/faction/faction_turn.dart: a turn of a faction: every action
## that rolls dice gets a freshly seeded generator, so the journal can write
## the dice down and a replay plays the same game without the brain.

var _seeds: DartRandom


func _init(game_: Game, player_: Player, executor: ActionExecutor, seeds: DartRandom) -> void:
	super(game_, seeds, [], player_, executor)
	_seeds = seeds


func random() -> DartRandom:
	return DartRandom.new(_seeds.next_int(0x7FFFFFFF))
