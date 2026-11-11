class_name ActionExecutor
extends RefCounted
## lib/domain/action/action_executor.dart: runs an action once it
## validates, then, if it succeeded, keeps its history entry and adds the
## noise it made to the player's raid gauge, and notes it in the game's
## replay journal, under the turn it was played in.


func execute(action: Action, game: Game, player: Player) -> ActionResult:
	var validation := action.validate(game, player)
	if not validation.is_success:
		return validation
	var turn := game.turn
	var result := action.execute(game, player)
	if result.is_success:
		if game.replay != null:
			var is_human := player.id == game.human_player_id
			game.replay.record(turn, action, null if is_human else player.id, game.human_player_id)
		var entry := action.make_history_entry(game, player, result, game.turn)
		if entry != null:
			player.add_history_entry(entry)
		player.raid_state.add_noise(action.noise_made(player))
	return result
