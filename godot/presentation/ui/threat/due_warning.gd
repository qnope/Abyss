class_name DueWarning
extends RefreshingPanel
## A warning of the end-of-turn question about a threat that strikes this turn:
## a separator, then one red line with its glyph. The text is a [Callable]
## called again whenever the language changes (the line is a [SummaryLine]).
## It never blocks the turn.

var column := VBoxContainer.new()
var line: SummaryLine


## A warning with the glyph [param glyph] (a file of assets/icons/ui) saying
## what [param text] returns.
func _init(glyph: StringName, text: Callable) -> void:
	super()
	line = SummaryLine.new(glyph, AbyssColors.ERROR, text)
	column.add_child(HSeparator.new())
	column.add_child(line)
	add_child(column)
