class_name GuideBubble
extends RefreshingPanel
## The guide of the tutorial, the octopus archivist, and what it says, at the
## bottom of the game screen (lib/.../guide_bubble.dart). Its button hides it
## until the advice changes, or, for an exploration, until the next turn.
## Nothing shows without advice.
##
## It follows the [GuideScope] it is given; [method show_advice] is what the
## scope tells it, and what a test says to it.

const PORTRAIT := "res://assets/icons/guide/octopus_archivist.svg"
const PORTRAIT_SIZE := 64.0
const MARGINS: Dictionary[StringName, int] = {&"margin_left": 8, &"margin_top": 4, &"margin_right": 8, &"margin_bottom": 6}
const GAP := 10

var advice: GuideAdvice
var turn := 0
var dismissed := false
var portrait := UiIcon.new(PORTRAIT, PORTRAIT_SIZE)
var message_label := Label.new()
var got_it := Button.new()
## The speech bubble the guide speaks in.
var panel := PanelContainer.new()


func _init(scope: GuideScope = null) -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	got_it.theme_type_variation = &"TextButton"
	got_it.size_flags_horizontal = Control.SIZE_SHRINK_END
	got_it.pressed.connect(_dismiss)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(message_label)
	words.add_child(got_it)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(portrait)
	row.add_child(words)
	panel.theme_type_variation = AbyssGuideTheme.BUBBLE
	panel.add_child(row)
	var margin := MarginContainer.new()
	for side: StringName in MARGINS:
		margin.add_theme_constant_override(side, MARGINS[side])
	margin.add_child(panel)
	add_child(margin)
	if scope != null:
		scope.changed.connect(func() -> void: show_advice(scope.advice, scope.turn))
		show_advice(scope.advice, scope.turn)
	else:
		refresh()


## Says [param next] at [param at_turn]. It comes back after « Compris » when
## it is a new advice, or an exploration to do at a new turn.
func show_advice(next: GuideAdvice, at_turn: int) -> void:
	var exploring := next != null and next.message is GuidePostToFind
	if not _same_message(advice, next) or (exploring and turn != at_turn):
		dismissed = false
	advice = next
	turn = at_turn
	refresh()


func refresh() -> void:
	visible = advice != null and not dismissed
	if advice != null:
		message_label.text = GuideMessageTexts.text(advice.message)
	got_it.text = Texts.t(&"commonGotIt")


func _dismiss() -> void:
	dismissed = true
	refresh()


static func _same_message(a: GuideAdvice, b: GuideAdvice) -> bool:
	if a == null or b == null:
		return a == b
	return a.message.equals(b.message)
