class_name FactionRankingSheet
extends BottomSheet
## The ranking of the human and the factions
## (lib/presentation/widgets/faction/faction_ranking_sheet.dart): a title over
## one [FactionStandingTile] each, the most advanced first. It tells nothing and
## changes nothing.

const TITLE_PADDING := 8

var standings: Array[FactionStanding]
var title_label := Label.new()
var tiles: Array[FactionStandingTile] = []


## The sheet of [param standings_] (`FactionStanding.ranking(game)`).
func _init(standings_: Array[FactionStanding]) -> void:
	standings = standings_
	super()
	title_label.theme_type_variation = &"TitleMedium"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_box := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		title_box.add_theme_constant_override("margin_" + side, TITLE_PADDING)
	title_box.add_child(title_label)
	body.add_child(title_box)
	body.add_child(HSeparator.new())
	for standing in standings:
		var tile := FactionStandingTile.new(standing)
		tiles.append(tile)
		body.add_child(tile)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"factionRankingTitle")
