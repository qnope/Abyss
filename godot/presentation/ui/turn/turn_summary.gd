class_name TurnSummary
extends AbyssDialog
## What a turn did, once it ended (lib/presentation/widgets/turn/
## turn_summary_dialog.dart): "Tour 3 → Tour 4", then the [SummarySections]
## of its [TurnResult], or that nothing changed. The sections scroll with the
## body when they are many; the OK is always in reach. It ends with null.

var result: TurnResult
var empty_label := Label.new()
var ok_button: Button


func _init(result_: TurnResult) -> void:
	result = result_
	super()
	var sections := SummarySections.of(result)
	for section in sections:
		body.add_child(section)
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.visible = sections.is_empty()
	body.add_child(empty_label)
	ok_button = add_action("", null, &"")
	refresh()


func refresh() -> void:
	# Called once by the base class, before the button is made.
	if ok_button == null:
		return
	set_title(Texts.t(&"turnTransition", {"from": result.previous_turn, "to": result.new_turn}))
	empty_label.text = Texts.t(&"turnNoChange")
	ok_button.text = Texts.t(&"commonOk")
