class_name GameStatusBars
extends VBoxContainer
## The strips stacked under the resource bar, each a Control of its own: the
## noise gauge or the raid alert, the guardians coming back, the kraken wave,
## the random events, then the current objective
## (lib/presentation/widgets/common/game_status_bars.dart). It holds none
## itself: the lot of each strip adds it with [method add_bar], and
## [method refresh] redraws those that follow the game.

const GAP := 0


func _init() -> void:
	add_theme_constant_override(&"separation", GAP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Stacks [param bar] under the ones already there.
func add_bar(bar: Control) -> void:
	add_child(bar)


## The strips, top to bottom.
func bars() -> Array[Control]:
	var found: Array[Control] = []
	for child in get_children():
		found.append(child as Control)
	return found


## Redraws the strips that show the state of the game (the RefreshingPanels).
func refresh() -> void:
	for bar in bars():
		if bar is RefreshingPanel:
			(bar as RefreshingPanel).refresh()
