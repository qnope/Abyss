class_name TechTab
extends RefreshingPanel
## The laboratory tab: the research tree (lib/presentation/screens/game/
## game_screen_tabs.dart, case 3: TechTreeView) over the world, which rests
## hidden behind it. A touch on a branch or a node opens its [TechTargetSheet]
## on the modals; the sheet changes the game through the [GameActions], and
## the owner calls [method refresh] after each change (and the language does
## it by itself). It saves nothing and navigates nothing.
##
## The tree is built again from the game only while the tab is on show: a
## refresh of a tab hidden in the scene tree only notes that the tree is out
## of date, and the tab builds it once when it is shown again. Building it
## costs far more than the rest of a refresh, and every action of the player
## on another tab asks for one. Out of the scene tree nothing tells whether
## the tab is on show, so the tree is built at once: [member tree] is there
## once the tab is built.
##
## Flow: node touched -> [signal TechTreeView.target_tapped] -> sheet ->
## [method GameActions.execute] -> [signal GameActions.acted] -> save ->
## [method refresh].

const PAD := 12

var actions: GameActions
## The tree on show, replaced each time it is built again.
var tree: TechTreeView
var scroll := ScrollContainer.new()
var _padding := MarginContainer.new()
var _modals: ModalLayer
## The game or the language changed since the tree was built.
var _stale := false


func _init(actions_: GameActions, modals: ModalLayer) -> void:
	super()
	actions = actions_
	_modals = modals
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "top", "right", "bottom"]:
		_padding.add_theme_constant_override("margin_" + side, PAD)
	scroll.add_child(_padding)
	add_child(scroll)
	refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and _stale and is_visible_in_tree():
		_build()


## Builds the tree again from the game, at once unless the tab is hidden in
## the scene tree: it then waits to be shown.
func refresh() -> void:
	# Called once by the base class, before there is a game to read.
	if actions == null:
		return
	if is_inside_tree() and not is_visible_in_tree():
		_stale = true
	else:
		_build()


func _build() -> void:
	_stale = false
	if tree != null:
		_padding.remove_child(tree)
		tree.free()
	tree = TechTreeView.new(TechView.of(actions.game), actions.guide)
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.target_tapped.connect(_open)
	_padding.add_child(tree)


func _open(target: TechTarget) -> void:
	_modals.open(TechTargetSheet.new(actions, target))
