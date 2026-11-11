class_name BaseIntelReport
extends RefreshingPanel
## What a Scout reported of a base, read on a turn
## (lib/presentation/widgets/faction/base_intel_report.dart): the rampart, the
## army and the stocks, and how long the report still holds.

const GAP := 4

var intel: BaseIntel
var turn: int
var title_label := Label.new()
var freshness_label := Label.new()
var rampart_row: SheetInfoRow
var army_row: SheetInfoRow
var stocks_row: SheetInfoRow


func _init(intel_: BaseIntel, turn_: int) -> void:
	intel = intel_
	turn = turn_
	super()
	title_label.theme_type_variation = &"TitleSmall"
	freshness_label.theme_type_variation = &"BodySmall"
	freshness_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var fresh := intel.is_fresh(turn)
	freshness_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM if fresh else AbyssColors.ERROR)
	rampart_row = SheetInfoRow.new(Texts.t.bind(&"factionIntelRampart"), func() -> String: return str(intel.rampart_level))
	army_row = SheetInfoRow.new(Texts.t.bind(&"factionIntelArmy"), _army)
	stocks_row = SheetInfoRow.new(Texts.t.bind(&"factionIntelStocks"), _stocks)
	for long_row: SheetInfoRow in [army_row, stocks_row]:
		_wrap(long_row)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	for part: Control in [title_label, freshness_label, rampart_row, army_row, stocks_row]:
		column.add_child(part)
	add_child(column)
	refresh()


## The value of a long row wraps, in two thirds of the row, so that the sheet
## keeps its width.
func _wrap(row: SheetInfoRow) -> void:
	row.value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.value_label.size_flags_stretch_ratio = 2.0


func refresh() -> void:
	# Called once by the base class, before the rows are made.
	if stocks_row == null:
		return
	title_label.text = Texts.t(&"factionIntelTitle")
	if intel.is_fresh(turn):
		freshness_label.text = Texts.t(&"factionIntelFresh", {"turns": intel.turns_left(turn)})
	else:
		freshness_label.text = Texts.t(&"factionIntelStale")
	for row: SheetInfoRow in [rampart_row, army_row, stocks_row]:
		row.refresh()


## The units standing on the base, "4 gardiens, 2 éclaireurs", or that none do.
func _army() -> String:
	var units: Array[String] = []
	for type: UnitType.Value in intel.army:
		if intel.army[type] > 0:
			units.append(UnitTexts.units(type, intel.army[type]))
	return ", ".join(units) if not units.is_empty() else Texts.t(&"factionIntelNoArmy")


func _stocks() -> String:
	var stocks: Array[String] = []
	for type: ResourceType.Value in intel.stocks:
		stocks.append("%s %d" % [ResourceTexts.display_name(type), intel.stocks[type]])
	return ", ".join(stocks)
