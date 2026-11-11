class_name FactionController
extends RefCounted
## The rival factions of the map (lib/presentation/screens/game/
## game_screen_faction_actions.dart, game_screen_rival_attack.dart): a touch on
## the base of a faction opens what is known of it, a Scout can be sent to
## spy on it, and its base, or a Faille, a Cheminée or the volcano it holds, can
## be assaulted.
##
## Flow: cell tapped -> [CellRouter] -> [FactionBaseSheet] -> `spy_requested` ->
## [SpyBaseAction] through [GameActions.execute] -> `acted` -> save -> `changed`
## -> the sheet opens again with the report; or `attack_requested` ->
## [ArmySelection] ([AssaultSelections.rival]) -> [AttackBaseAction] ->
## `acted` -> save -> `changed` (the map is redrawn) -> the page closes with the
## result -> [BaseAssaultSummaryPage]. A refusal stays in the selection page. A
## post or the volcano another player holds opens a [RivalPostSheet] (made by
## [PostController] and [KernelController], which tell
## `rival_attack_requested`) and goes the same way with [AttackPostAction] or
## [AttackHeldKernelAction].
##
## It registers itself for the faction bases on the router it is given and
## keeps nothing of it: whoever made it holds it as long as the screen is played.
## The assault played on the map before the report is step 7's.

var actions: GameActions
var modals: ModalLayer


func _init(actions_: GameActions, router: CellRouter, modals_: ModalLayer, post: PostController, kernel: KernelController) -> void:
	actions = actions_
	modals = modals_
	router.register(CellRoute.Kind.FACTION_BASE, open_base)
	post.rival_attack_requested.connect(_attack_post)
	kernel.rival_attack_requested.connect(_attack_kernel)


## Opens the sheet of the faction whose base stands on the cell of [param route].
func open_base(route: CellRoute) -> void:
	var game := actions.game
	var human := game.human_player()
	var faction := _faction_at(route.x, route.y)
	var target: Player = game.players[faction.id()]
	var intel: BaseIntel = human.intel().get(target.id)
	var sheet := FactionBaseSheet.new(faction, target.buildings[BuildingType.Value.HEADQUARTERS].level,
		AttackBaseValidator.refusal(game, human, target.id), intel, game.turn,
		SpyBaseAction.refusal(game, human, target.id))
	sheet.spy_requested.connect(_spy.bind(route, target))
	sheet.attack_requested.connect(_assault.bind(target, AttackBaseAction.LEVEL, null,
		func(picks: Dictionary[UnitType.Value, int]) -> Action:
			return AttackBaseAction.new(target.id, picks, SeededRandom.fresh())))
	modals.open(sheet)


## Sends a Scout to the base of [param target], and opens its sheet again with
## the report (or tells why the Scout could not go).
func _spy(route: CellRoute, target: Player) -> void:
	var result := actions.execute(SpyBaseAction.new(target.id))
	if result.is_success:
		open_base(route)
		return
	modals.open(MessageDialog.new("", func() -> String: return ActionFailureTexts.failure_message(result)))


func _attack_post(owner: Player, level: int, x: int, y: int) -> void:
	var post := actions.game.levels[level].cell_at(x, y).transition_base
	_assault(owner, level, post.name, func(picks: Dictionary[UnitType.Value, int]) -> Action:
		return AttackPostAction.new(x, y, level, picks, SeededRandom.fresh()))


func _attack_kernel(owner: Player, level: int, x: int, y: int) -> void:
	_assault(owner, level, AttackHeldKernelAction.KERNEL_CODE, func(picks: Dictionary[UnitType.Value, int]) -> Action:
		return AttackHeldKernelAction.new(x, y, picks, SeededRandom.fresh()))


## Opens the choice of the army to send from [param level] against [param target]:
## [param make] builds the action from the picks, and the report opens once the
## assault is over. [param post_name] is the post (or the kernel) attacked, null
## for the base.
func _assault(target: Player, level: int, post_name: Variant, make: Callable) -> void:
	var send := func(picks: Dictionary[UnitType.Value, int]) -> ActionResult:
		var action: Action = make.call(picks)
		return actions.execute(action)
	var page := AssaultSelections.rival(actions.game.human_player(), level, target.name, send)
	page.closed.connect(_report.bind(target, post_name))
	modals.open(page)


## Opens the report of the assault [param result] made on [param target].
func _report(result: Variant, target: Player, post_name: Variant) -> void:
	var assault: AttackBaseResult = result
	if assault != null:
		var entry := AttackBaseEntries.for_attacker(actions.game.turn, target.name, assault, post_name)
		modals.open(BaseAssaultSummaryPage.new(entry))


## The faction whose base stands on ([param x], [param y]) of the first level.
func _faction_at(x: int, y: int) -> Faction:
	var found: Faction
	for faction in actions.game.factions():
		var player: Player = actions.game.players[faction.id()]
		if player.base_x == x and player.base_y == y:
			found = faction
	return found
