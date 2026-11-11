class_name TutorialStrategy
extends GameScript
## lib/domain/script/strategies/tutorial_strategy.dart: "Tutoriel", a
## newcomer who follows the guide of the first chapter to the letter, one
## objective at a time, then plays like `then`.
##
## It answers the random events and, once the step of the turn is played,
## recruits the Harpoonists the guide advises against the first raid. Once
## the first chapter is done or the first raid fought, `then` plays the rest
## of the game.

var then: ConquestStrategy


## `then_` null is a ConquestStrategy of its defaults.
func _init(then_: ConquestStrategy = null) -> void:
	then = then_ if then_ != null else ConquestStrategy.new()


func name() -> String:
	return "tutorial"


func play_turn(turn: ScriptTurn) -> void:
	var step := TutorialMoves.tutorial_step(turn)
	if step == null:
		then.play_turn(turn)
		return
	EventMoves.play_events(turn, then.planner)
	TutorialMoves.follow_step(turn, step.id)
	if turn.player.raid_state.is_incoming():
		TutorialMoves.follow_raid_advice(turn, then.planner)
