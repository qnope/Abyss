class_name AttackHeldKernelAction
extends Action
## lib/domain/action/attack_held_kernel_action.dart: sends `selected_units`
## of the volcano level against the volcanic kernel that another player
## holds, defended by its garrison and the magma rampart; without either it
## falls at once.
##
## A won attack takes one level off the kernel. When the kernel reaches
## level 0 the attacker holds it (and the garrison is lost with it), but can
## put no garrison there before it has built the kernel up to level 1.
## There is no pillage. Both players keep a BaseAssaultEntry whose rampart
## levels are the kernel's.

## Code of the post in the history entries of this attack.
const KERNEL_CODE := "volcanicKernel"

var target_x: int
var target_y: int
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom

var _owner_name := ""


func _init(
	target_x_: int, target_y_: int, selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null
) -> void:
	target_x = target_x_
	target_y = target_y_
	selected_units = selected_units_
	random = random_


func type() -> ActionType.Value:
	return ActionType.Value.ATTACK_HELD_KERNEL


func description() -> String:
	return "Assaut Noyau tenu (%d, %d)" % [target_x, target_y]


func validate(game: Game, player: Player) -> ActionResult:
	var failure: Variant = AttackHeldKernelValidator.check(game, player, target_x, target_y, selected_units)
	if failure == null:
		return ActionResult.success()
	var reason: ActionFailure.Value = failure
	return AttackBaseResult.failure(reason)


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var level := KernelGarrison.VOLCANO_LEVEL
	var map: GameMap = game.levels[level]
	var owner: Player = game.players[map.cell_at(target_x, target_y).collected_by]
	_owner_name = owner.name
	var defence := BaseDefence.kernel(owner)
	AttackTransitionBaseHelpers.remove_units_from_stock(player, level, selected_units)
	var fight := FightEngine.new(random).resolve(
		CombatantBuilder.player_combatants_from(selected_units, FightMonsterHelpers.unit_boost_of(player, true)),
		defence.side,
	)
	var breakdown := FightMonsterHelpers.resolve_casualties(player, level, fight, random)
	var outcome := defence.settle(owner, random)
	var before := KernelGarrison.kernel_level_of(owner)
	var after := maxi(0, before - 1) if fight.is_victory() else before
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	var result := AttackBaseResult.success(
		fight.is_victory(), fight, sent, breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
		outcome, BaseDamage.kernel(before, after),
	)
	KernelAssaultSettlement.settle(game, target_x, target_y, player, owner, result, KERNEL_CODE)
	return result


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is AttackBaseResult or not result.is_success:
		return null
	var assault: AttackBaseResult = result
	return AttackBaseEntries.for_attacker(turn, _owner_name, assault, KERNEL_CODE)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
