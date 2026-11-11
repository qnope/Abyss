class_name AssaultLineCard
extends FightReportCard
## A report card with a line of text, or several (Flutter's
## `FightReportCard.line` and the columns of lines of `AssaultDamageCard` and
## `AssaultKernelCard`): each line is written by a function, so that the card
## follows the language.

var lines: Array[Label] = []
var _sources: Array[Callable]


## A card whose lines are what [param sources] (functions returning a String)
## write.
func _init(sources: Array[Callable]) -> void:
	_sources = sources
	super()
	for source in _sources:
		var line := text_label()
		lines.append(line)
		column.add_child(line)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the lines are made.
	for index in lines.size():
		lines[index].text = _sources[index].call()
