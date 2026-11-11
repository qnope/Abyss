class_name GameTabBar
extends RefreshingPanel
## The navigation at the foot of the game screen: Base, Map, Army and Tech,
## each an icon over its name, the one on show lit in cyan
## (lib/presentation/widgets/common/game_bottom_bar.dart: the tab bar). A
## touch tells [signal tab_chosen], even on the lit tab, and lights the tab
## at once; [method select] lights one from outside without a signal. The
## tabs are the buttons of one ButtonGroup, so they are one choice among
## four for the keyboard and screen readers.

## The player touched [param tab].
signal tab_chosen(tab: GameTab.Value)

## The height of a tab, as Flutter's bottom navigation bar.
const TAB_HEIGHT := 56.0

var _buttons: Dictionary[GameTab.Value, Button] = {}


func _init() -> void:
	super()
	theme_type_variation = AbyssChromeTheme.BAR
	var row := HBoxContainer.new()
	var group := ButtonGroup.new()
	for tab: GameTab.Value in GameTab.Value.values():
		var button := Button.new()
		button.theme_type_variation = AbyssChromeTheme.ITEM
		button.toggle_mode = true
		button.button_group = group
		button.icon = load(GameTab.icon_path(tab)) as Texture2D
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = TAB_HEIGHT
		button.pressed.connect(tab_chosen.emit.bind(tab))
		_buttons[tab] = button
		row.add_child(button)
	add_child(row)
	select(GameTab.Value.BASE)
	refresh()


## Lights [param tab] without telling it.
func select(tab: GameTab.Value) -> void:
	for each: GameTab.Value in _buttons:
		_buttons[each].set_pressed_no_signal(each == tab)


## The tab lit.
func selected() -> GameTab.Value:
	var lit := GameTab.Value.BASE
	for tab: GameTab.Value in _buttons:
		if _buttons[tab].button_pressed:
			lit = tab
	return lit


## The button of [param tab].
func button(tab: GameTab.Value) -> Button:
	return _buttons[tab]


func refresh() -> void:
	for tab: GameTab.Value in _buttons:
		_buttons[tab].text = GameTab.label(tab)
