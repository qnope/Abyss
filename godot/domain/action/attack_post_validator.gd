class_name AttackPostValidator
extends RefCounted
## lib/domain/action/attack_post_validator.dart: the rules that say whether
## a player may attack a post, a Faille or a Cheminée, that another player
## holds. Each failure is an ActionFailure.Value, or null when there is
## none.


## Why the attack on the post of `level` at (`x`, `y`) with `army` is
## refused, null if it is not. The army comes from the units of `level`, as
## when a post is captured from its guardians.
static func check(
	game: Game, player: Player, level: int, x: int, y: int, army: Dictionary[UnitType.Value, int]
) -> Variant:
	var refused: Variant = refusal(game, player, level, x, y)
	return refused if refused != null else AttackBaseValidator.army_failure(player, army, level)


## Why `player` may not attack this post at all, whatever the army.
static func refusal(game: Game, player: Player, level: int, x: int, y: int) -> Variant:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return ActionFailure.Value.MAP_NOT_GENERATED
	var cell := map.cell_at(x, y)
	if cell.content != CellContentType.Value.TRANSITION_BASE:
		return ActionFailure.Value.NO_TRANSITION_BASE_HERE
	var post := cell.transition_base
	if post == null:
		return ActionFailure.Value.BASE_NOT_FOUND
	if post.captured_by == null:
		return ActionFailure.Value.BASE_NOT_CAPTURED
	if post.captured_by == player.id:
		return ActionFailure.Value.CANNOT_ATTACK_SELF
	var owner: Player = game.players.get(post.captured_by)
	if owner == null:
		return ActionFailure.Value.NO_SUCH_PLAYER
	if owner.has_fallen():
		return ActionFailure.Value.PLAYER_FALLEN
	if AttackBaseValidator.is_protected(game, player) or AttackBaseValidator.is_protected(game, owner):
		return ActionFailure.Value.ATTACK_TOO_EARLY
	if player.id == game.human_player_id and not player.revealed_cells_set_on_level(level).has(Vector2i(x, y)):
		return ActionFailure.Value.BASE_NOT_REVEALED
	if AttackCooldown.on_posts(game, player, owner):
		return ActionFailure.Value.ATTACK_TOO_SOON
	return AttackBaseValidator.already_hit(game, player, owner)
