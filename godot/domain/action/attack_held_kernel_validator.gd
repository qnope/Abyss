class_name AttackHeldKernelValidator
extends RefCounted
## lib/domain/action/attack_held_kernel_validator.dart: the rules that say
## whether a player may attack the volcanic kernel another player holds.
## Each failure is an ActionFailure.Value, or null when there is none.


## Why the attack on the kernel at (`x`, `y`) with `army` is refused, null
## if it is not. The army comes from the volcano level.
static func check(game: Game, player: Player, x: int, y: int, army: Dictionary[UnitType.Value, int]) -> Variant:
	var refused: Variant = refusal(game, player, x, y)
	if refused != null:
		return refused
	return AttackBaseValidator.army_failure(player, army, KernelGarrison.VOLCANO_LEVEL)


## Why `player` may not attack this kernel at all, whatever the army.
static func refusal(game: Game, player: Player, x: int, y: int) -> Variant:
	var map: GameMap = game.levels.get(KernelGarrison.VOLCANO_LEVEL)
	if map == null:
		return ActionFailure.Value.MAP_NOT_GENERATED
	var cell := map.cell_at(x, y)
	if cell.content != CellContentType.Value.VOLCANIC_KERNEL:
		return ActionFailure.Value.NO_VOLCANIC_KERNEL_HERE
	if cell.collected_by == null:
		return ActionFailure.Value.KERNEL_NOT_CAPTURED
	if cell.collected_by == player.id:
		return ActionFailure.Value.CANNOT_ATTACK_SELF
	var owner: Player = game.players.get(cell.collected_by)
	if owner == null:
		return ActionFailure.Value.NO_SUCH_PLAYER
	if owner.has_fallen():
		return ActionFailure.Value.PLAYER_FALLEN
	if AttackBaseValidator.is_protected(game, player) or AttackBaseValidator.is_protected(game, owner):
		return ActionFailure.Value.ATTACK_TOO_EARLY
	if (
		player.id == game.human_player_id
		and not player.revealed_cells_set_on_level(KernelGarrison.VOLCANO_LEVEL).has(Vector2i(x, y))
	):
		return ActionFailure.Value.BASE_NOT_REVEALED
	if AttackCooldown.on_kernel(game, player, owner):
		return ActionFailure.Value.ATTACK_TOO_SOON
	return AttackBaseValidator.already_hit(game, player, owner)
