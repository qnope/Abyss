class_name TechTab
extends RefreshingPanel
## The laboratory tab: the research tree (lib/presentation/screens/game/
## game_screen_tabs.dart, case 3: TechTreeView) over the world, which rests
## hidden behind it. A touch on a branch or a node opens its [TechTargetSheet]
## on the modals; the sheet changes the game through the [GameActions], and
## the owner calls [method refresh] after each change (and the language does
## it by itself): the tree is built again from the game. It saves nothing and
## navigates nothing.
##
## Flow: node touched -> [signal TechTreeView.target_tapped] -> sheet ->
## [method GameActions.execute] -> [signal GameActions.acted] -> save ->
## [method refresh].

const PAD := 12

var actions: GameActions
## The tree on show, replaced on each refresh.
var tree: TechTreeView
var scroll := ScrollContainer.new()
var _padding := MarginContainer.new()
var _modals: ModalLayer


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


## Builds the tree again from the game.
func refresh() -> void:
	# Called once by the base class, before there is a game to read.
	if actions == null:
		return
	if tree != null:
		_padding.remove_child(tree)
		tree.free()
	tree = TechTreeView.new(TechView.of(actions.game), actions.guide)
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.target_tapped.connect(_open)
	_padding.add_child(tree)


func _open(target: TechTarget) -> void:
	_modals.open(TechTargetSheet.new(actions, target))
