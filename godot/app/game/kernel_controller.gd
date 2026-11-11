class_name KernelController
extends RefCounted
## The volcano of the map (lib/presentation/screens/game/
## game_screen_kernel_actions.dart): a touch on it opens its sheet, the assault
## opens the choice of the army and then its report, and once it is the
## player's, its garrison is filled or emptied through a picker.
##
## Flow: cell tapped -> [CellRouter] -> [VolcanicKernelSheet] ->
## `attack_requested` -> [ArmySelection] -> [AttackVolcanicKernelAction]
## through [GameActions.execute] -> `acted` -> save -> `changed` -> the page
## closes with the result -> [KernelFightSummaryPage]; a refusal stays in the
## selection page. The garrison is `garrison_requested` / `withdraw_requested`
## -> [UnitPickerDialog] -> [GarrisonKernelAction], whose size (or refusal) a
## [MessageDialog] tells. The victory a kernel raised to the last level brings
## is the session's: [signal GameActions.victory_reached].
##
## The sheet and the selection of a volcano still guarded show the plan of the
## assault ([AssaultPlans]); the selection's follows the units picked.
##
## It registers itself for the volcano on the router it is given. A volcano
## another player holds opens a [RivalPostSheet] and its attack is
## [FactionController]'s: [signal rival_attack_requested] tells it.

## The player wants to attack the volcano [param owner] holds at ([param x],
## [param y]) of [param level].
signal rival_attack_requested(owner: Player, level: int, x: int, y: int)

var actions: GameActions
var modals: ModalLayer


func _init(actions_: GameActions, router: CellRouter, modals_: ModalLayer) -> void:
	actions = actions_
	modals = modals_
	router.register(CellRoute.Kind.KERNEL, open_kernel)


## Opens the sheet of the volcano of [param route].
func open_kernel(route: CellRoute) -> void:
	var human := actions.game.human_player()
	var owner := HeldBy.player(actions.game, route.cell.collected_by)
	if owner != null and owner != human:
		var refusal: Variant = AttackHeldKernelValidator.refusal(actions.game, human, route.x, route.y)
		var rival := RivalPostSheet.new(null, owner.name, refusal)
		rival.attack_requested.connect(func() -> void:
			rival_attack_requested.emit(owner, route.level, route.x, route.y))
		modals.open(rival)
		return
	var plan := AssaultPlans.sheet_panel(actions.game, route.level, route.x, route.y)
	var sheet := VolcanicKernelSheet.new(actions.game, owner == human, plan)
	sheet.attack_requested.connect(_select_assault.bind(route))
	sheet.garrison_requested.connect(_pick_garrison.bind(false))
	sheet.withdraw_requested.connect(_pick_garrison.bind(true))
	modals.open(sheet)


func _select_assault(route: CellRoute) -> void:
	var plan := AssaultPlans.selection_panel(actions.game, route.level, route.x, route.y)
	var page := AssaultSelections.kernel(actions.game.human_player(), route.level, _assault.bind(route), plan)
	AssaultPlans.track(page, plan, actions.game, route.level, route.x, route.y)
	page.closed.connect(_on_assaulted.bind(route))
	modals.open(page)


func _assault(picks: Dictionary[UnitType.Value, int], route: CellRoute) -> ActionResult:
	return actions.execute(AttackVolcanicKernelAction.new(route.x, route.y, route.level, picks, SeededRandom.fresh()))


## Opens the report of the assault [param result] made on the cell of [param route].
func _on_assaulted(result: Variant, route: CellRoute) -> void:
	var assault: AttackVolcanicKernelResult = result
	if assault != null:
		modals.open(KernelFightSummaryPage.new(assault, route.x, route.y))


## Opens the picker of the units to put in the garrison (those standing on the
## volcano level), or to take out of it ([param withdraw]).
func _pick_garrison(withdraw: bool) -> void:
	var level := KernelGarrison.STOCK_KEY if withdraw else KernelGarrison.VOLCANO_LEVEL
	var dialog := UnitPickerDialog.new(
		Texts.t(&"screenGarrisonWithdrawTitle" if withdraw else &"screenGarrisonSendTitle"),
		actions.game.human_player().units_on_level(level),
		Texts.t(&"screenGarrisonWithdraw" if withdraw else &"commonSend"),
		Texts.t(&"screenGarrisonWithdrawInfo" if withdraw else &"screenGarrisonSendInfo"))
	dialog.closed.connect(_on_garrison_picked.bind(withdraw))
	modals.open(dialog)


## Moves the units [param picked] in or out of the garrison, and tells its size.
func _on_garrison_picked(picked: Variant, withdraw: bool) -> void:
	if picked == null:
		return
	var picks: Dictionary[UnitType.Value, int] = picked
	var result := actions.execute(GarrisonKernelAction.new(picks, withdraw))
	if not result.is_success:
		modals.open(MessageDialog.new("", func() -> String: return ActionFailureTexts.failure_message(result)))
		return
	var size := KernelGarrison.size_of(actions.game.human_player())
	modals.open(MessageDialog.new("", func() -> String: return Texts.t(&"screenGarrisonSize", {"count": size})))
