class_name LeviathanResolver
extends RefCounted
## lib/domain/leviathan/leviathan_resolver.dart: "the Léviathan comes back"
## (LeviathanReturn): scheduled by the first Faille the human takes,
## postponed while its Module de descente does not work (nobody could defend
## it), announced by the end of the turn before it strikes, fought at the
## end of the turn it strikes, like a volcano wave. It is cancelled when the
## human no longer holds the Faille. Its LeviathanTurnOutcome has a file of
## its own.


## `player` took `base` at `at` on `level` during the current turn.
static func on_capture(game: Game, player: Player, base: TransitionBase, level: int, at: GridPosition) -> void:
	var state := game.leviathan_return
	if (
		state == null
		or not state.is_available()
		or player.id != game.human_player_id
		or base.type != TransitionBaseType.Value.FAILLE
	):
		return
	state.schedule(base.name, level, at, game.turn)
	_mark_ready(game, state)


## The attack the human faces at the end of the current turn, if any.
static func announced_now(game: Game) -> LeviathanAnnouncement:
	var state := game.leviathan_return
	if state == null or state.due_turn() != game.turn:
		return null
	return null if _post_of(game, state) == null else _announcement(state)


## End-of-turn step, before the turn counter moves on: fights the guardians
## due at the end of this turn, or announces them for the next one.
static func resolve(game: Game, random: DartRandom = null) -> LeviathanTurnOutcome:
	var state := game.leviathan_return
	if state == null or not state.is_scheduled():
		return LeviathanTurnOutcome.new()
	var ended := game.turn
	_mark_ready(game, state)
	var due: Variant = state.due_turn()
	if due == null:
		return LeviathanTurnOutcome.new()
	var strike: int = due
	if strike > ended + 1:
		return LeviathanTurnOutcome.new()
	var post := _post_of(game, state)
	if post == null:
		state.end()
		return LeviathanTurnOutcome.new()
	if strike == ended + 1:
		return LeviathanTurnOutcome.new(null, _announcement(state))
	state.end()
	return LeviathanTurnOutcome.new(LeviathanBattle.fight(game, post, ended, random))


## Records the turn the Module first works while the Faille is held.
static func _mark_ready(game: Game, state: LeviathanReturn) -> void:
	if state.ready_turn != null or _post_of(game, state) == null:
		return
	if PostTakeover.passage_works(game.human_player(), TransitionBaseType.Value.FAILLE):
		state.mark_ready(game.turn)


## The Faille, while the human still holds it.
static func _post_of(game: Game, state: LeviathanReturn) -> TransitionBase:
	if not state.is_scheduled():
		return null
	var at: GridPosition = state.at
	var map: GameMap = game.levels.get(state.level)
	var post: TransitionBase = map.cell_at(at.x, at.y).transition_base if map != null else null
	if post != null and post.captured_by == game.human_player_id:
		return post
	return null


static func _announcement(state: LeviathanReturn) -> LeviathanAnnouncement:
	var post_name: String = state.post_name
	var level: int = state.level
	var due: int = state.due_turn()
	return LeviathanAnnouncement.new(post_name, level, state.at, due)
