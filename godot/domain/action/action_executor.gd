class_name ActionExecutor
extends RefCounted
## lib/domain/action/action_executor.dart: runs an action once it
## validates, then, if it succeeded, keeps its history entry and adds the
## noise it made to the player's raid gauge.
##
## Dart also notes the action in the game's replay journal
## (`game.replay?.record`): `ReplayJournal.record` needs `ActionEncoder`,
## which waits for every action (domain/README.md, "Left for a later lot").


func execute(action: Action, game: Game, player: Player) -> ActionResult:
	var validation := action.validate(game, player)
	if not validation.is_success:
		return validation
	var result := action.execute(game, player)
	if result.is_success:
		var entry := action.make_history_entry(game, player, result, game.turn)
		if entry != null:
			player.add_history_entry(entry)
		player.raid_state.add_noise(action.noise_made(player))
	return result
