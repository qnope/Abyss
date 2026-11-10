class_name GarrisonKernelAction
extends Action
## lib/domain/action/garrison_kernel_action.dart: moves units from the
## volcano level into the kernel's garrison, or back out when `withdraw` is
## set.

var selected_units: Dictionary[UnitType.Value, int]
var withdraw: bool


func _init(selected_units_: Dictionary[UnitType.Value, int], withdraw_ := false) -> void:
	selected_units = selected_units_
	withdraw = withdraw_


func type() -> ActionType.Value:
	return ActionType.Value.GARRISON_KERNEL


func description() -> String:
	return "Retirer de la garnison" if withdraw else "Mettre en garnison"


func validate(game: Game, player: Player) -> ActionResult:
	if not game.is_volcanic_kernel_captured_by(player.id):
		return ActionResult.failure(ActionFailure.Value.KERNEL_NOT_CAPTURED)
	if not withdraw and player.is_degraded(BuildingType.Value.VOLCANIC_KERNEL):
		return ActionResult.failure(ActionFailure.Value.KERNEL_DEGRADED)
	if not withdraw and KernelGarrison.kernel_level_of(player) < 1:
		return ActionResult.failure(ActionFailure.Value.KERNEL_NOT_BUILT)
	var total := 0
	var from := _from(player)
	for type: UnitType.Value in selected_units:
		var count := selected_units[type]
		if count <= 0:
			continue
		if count > Unit.count_in(from, type):
			return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
		total += count
	if total <= 0:
		return ActionResult.failure(ActionFailure.Value.NO_UNIT_SELECTED)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var from := _from(player)
	var to := KernelGarrison.stock_at(
		player, KernelGarrison.VOLCANO_LEVEL if withdraw else KernelGarrison.STOCK_KEY
	)
	for type: UnitType.Value in selected_units:
		var count := selected_units[type]
		if count <= 0:
			continue
		from[type].count -= count
		to[type].count += count
	return ActionResult.success()


func _from(player: Player) -> Dictionary[UnitType.Value, Unit]:
	return player.units_on_level(KernelGarrison.STOCK_KEY if withdraw else KernelGarrison.VOLCANO_LEVEL)
