class_name ArmyTab
extends RefreshingPanel
## The 2D part of the army tab, over the parade ground in 3D
## (lib/presentation/screens/game/game_screen_army_tab.dart and
## widgets/army/army_places_view.dart): the rampart's badge at the top left,
## and, floating at the bottom while the army serves in more than one place,
## the bar of its places ([ArmyPlaceBar]): "Toutes" stands the whole army on
## the ground, a place only the units it holds. The green plus of the
## recruitable types shows under "Toutes" and at the place where recruits
## arrive.
##
## The place shown is the tab's own, not saved, and back to "Toutes" once it
## holds no unit. [signal changed] tells the roster the parade shows, on each
## refresh and each choice of a place; [method refresh] redraws it from the
## game, the owner calls it after each change. It touches the world's touches
## nowhere but on the bar's segments.

## The army to show changed (or was redrawn): [param roster] is what stands on
## the ground at the place shown.
signal changed(roster: ArmyRoster)

## How far the badge sits from the corner.
const CORNER := 8

var game: Game
## The place shown: a level, the kernel's stock, or [constant ArmyPlaces.ALL].
var place := ArmyPlaces.ALL
var places: ArmyPlaces
var roster: ArmyRoster
var shield: ShieldBadge
var place_bar: ArmyPlaceBar


func _init(game_: Game) -> void:
	super()
	game = game_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	places = ArmyPlaces.of(game.human_player())
	shield = ShieldBadge.new(game.human_player().buildings)
	place_bar = ArmyPlaceBar.new(places)
	place_bar.chosen.connect(choose)
	var corner := MarginContainer.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "top"]:
		corner.add_theme_constant_override("margin_" + side, CORNER)
	shield.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	corner.add_child(shield)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for part: Control in [corner, spacer, place_bar]:
		column.add_child(part)
	add_child(column)
	refresh()


## Shows the army of [param next], "Toutes" for [constant ArmyPlaces.ALL].
func choose(next: int) -> void:
	place = next
	place_bar.select(place)
	_publish()


## Redraws the places, the badge and the army from the game.
func refresh() -> void:
	# Called once by the base class, before there is a game to show.
	if game == null:
		return
	places = ArmyPlaces.of(game.human_player())
	if not places.is_split() or not places.held().has(place):
		place = ArmyPlaces.ALL
	place_bar.show_places(places, place)
	place_bar.visible = places.is_split()
	shield.refresh()
	_publish()


## How many units of [param type] serve at the place shown.
func count_of(type: UnitType.Value) -> int:
	return places.count_of(type, place)


## The army at the place shown. Recruits arrive at the first level, so
## the types that can recruit show only under "Toutes" and there.
func _publish() -> void:
	var human := game.human_player()
	var recruiting := place == ArmyPlaces.ALL or place == RecruitUnitAction.ARRIVAL_LEVEL
	var recruitable: Dictionary[UnitType.Value, bool] = {}
	if recruiting:
		recruitable = RecruitableUnits.of(human)
	roster = ArmyRoster.new(Building.level_in(human.buildings, BuildingType.Value.BARRACKS),
		places.counts_at(place), recruitable)
	changed.emit(roster)
