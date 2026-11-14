class_name BenchLayer
extends MarginContainer
## The bench of the game's actions, laid over the real game: the frame
## counter, which the game's HUD has not, at the foot of the area the bars
## leave clear, and the [ActionBench] that plays the actions and times them.
## [method open] plays the [BenchGame] through the app's flow as any game is,
## on its Map tab; its saves ([BenchSaves]) are removed once the bench is over.
## A game played without it has neither the counter nor the bench.

## The gap between the counter and the edges of the clear area, in points.
const MARGIN := 8

var counter := FrameCounter.new()
var run: ActionBench
var _saves: BenchSaves


## Times the [param actions] of a game for [param seconds], then removes
## [param saves], where that game is saved.
func _init(actions: GameActions, saves: BenchSaves, seconds: float) -> void:
	_saves = saves
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		add_theme_constant_override(side, MARGIN)
	counter.size_flags_horizontal = SIZE_SHRINK_BEGIN
	counter.size_flags_vertical = SIZE_SHRINK_END
	add_child(counter)
	run = ActionBench.new(actions, counter, seconds)
	run.finished.connect(_on_finished)
	add_child(run)


## Plays the bench game through [param flow], whose repository is that of
## [param saves], shows its map and lays the bench over it.
static func open(flow: AppFlow, saves: BenchSaves, seconds: float) -> BenchLayer:
	flow.play(BenchGame.game())
	var hud := flow.current as GameHud
	hud.show_tab(GameTab.Value.MAP)
	var bench := BenchLayer.new(flow.controller.session.actions, saves, seconds)
	hud.content.add_child(bench)
	return bench


func _on_finished(_summary: String) -> void:
	_saves.remove()
