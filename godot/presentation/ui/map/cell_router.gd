class_name CellRouter
extends RefCounted
## Where a touch on a cell of the map leads (lib/presentation/screens/game/
## game_screen_map_actions.dart, `_showCellAction`): it opens the sheet of the
## cell on the [ModalLayer]. The sheets of the cells with nothing to do, the
## exploration and the treasure are its own.
##
## The kinds with a sheet that another lot builds (a lair, a post, the volcano,
## a rival's base: [constant CellRoute.Kind.LAIR], POST, KERNEL, FACTION_BASE)
## are handed to whoever [method register]ed for the kind, with the
## [CellRoute]; until then they open a "coming soon" sheet. The handler opens
## its own modals on [member modals] and acts through [member actions].

var actions: GameActions
var modals: ModalLayer
## What each registered kind does with its route (a Callable taking a
## [CellRoute]).
var handlers: Dictionary[CellRoute.Kind, Callable] = {}


func _init(actions_: GameActions, modals_: ModalLayer) -> void:
	actions = actions_
	modals = modals_


## Has [param handler] open the cells of [param kind], in place of whatever
## opened them until now.
func register(kind: CellRoute.Kind, handler: Callable) -> void:
	handlers[kind] = handler


## Opens the sheet of the touch on the cell ([param x], [param y]) of
## [param level].
func route(level: int, x: int, y: int) -> void:
	var found := CellRoute.of(actions.game, level, x, y)
	if handlers.has(found.kind):
		handlers[found.kind].call(found)
		return
	match found.kind:
		CellRoute.Kind.EXPLORE:
			modals.open(ExplorationSheet.new(actions, found.x, found.y, level))
		CellRoute.Kind.TREASURE:
			_open_treasure(found)
		CellRoute.Kind.VISITED:
			_info(UiIcon.glyph(&"check", 64.0, AbyssColors.SUCCESS), &"screenAlreadyVisitedTitle", &"screenAlreadyVisitedMessage")
		CellRoute.Kind.TAKEN:
			_taken(found)
		CellRoute.Kind.HOME:
			_info(UiIcon.glyph(&"home", 64.0, AbyssColors.BIOLUM_CYAN), &"screenYourBaseTitle", &"screenYourBaseMessage")
		CellRoute.Kind.PASSAGE:
			_passage(found)
		CellRoute.Kind.PLAIN:
			modals.open(CellInfoSheet.new(null, func() -> String: return Texts.t(&"screenPlainTitle", {"x": found.x, "y": found.y}),
				func() -> String: return Texts.t(&"screenNothingToSee")))
		_:
			modals.open(CellInfoSheet.new(null, func() -> String: return Texts.t(&"screenComingSoon"),
				func() -> String: return "(%d, %d)" % [found.x, found.y]))


func _info(picture: Control, title: StringName, message: StringName) -> void:
	modals.open(CellInfoSheet.new(picture, func() -> String: return Texts.t(title),
		func() -> String: return Texts.t(message)))


## A cell a rival emptied: its emblem and its name.
func _taken(found: CellRoute) -> void:
	var emblem := UiIcon.new(RivalEmblem.path_of(found.rival.personality), 64.0)
	var taker: Player = actions.game.players[found.rival.id()]
	modals.open(CellInfoSheet.new(emblem,
		func() -> String: return Texts.t(&"screenTakenByRivalTitle", {"name": taker.name}),
		func() -> String: return Texts.t(&"screenTakenByRivalMessage")))


## The arrival of a passage, lit by whoever holds the post above.
func _passage(found: CellRoute) -> void:
	var stored: Variant = found.cell.passage_name
	modals.open(CellInfoSheet.new(PassagePicture.of(actions.game, found.level, found.x, found.y),
		func() -> String: return Texts.t(&"screenPassageTitle", {"name": PassageName.of(stored)}),
		func() -> String: return Texts.t(&"screenPassageMessage")))


## The search of a treasure; what it found is told once it is done.
func _open_treasure(found: CellRoute) -> void:
	var sheet := TreasureSheet.new(actions, found.x, found.y, found.level)
	sheet.closed.connect(_tell_found.bind(found.cell.content))
	modals.open(sheet)


func _tell_found(result: Variant, content: CellContentType.Value) -> void:
	var found: CollectTreasureResult = result
	if found == null:
		return
	modals.open(ResourceGainDialog.new(CollectMessages.title_for(content), found.deltas,
		CollectMessages.empty_message_for(content)))
