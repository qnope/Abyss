class_name ArmyPlaceBar
extends RefreshingPanel
## Where the army is, at the bottom of the parade ground: "Toutes" then each
## place holding units ("Niv. 1", "Niv. 2", "Niv. 3", "Noyau"), each with its
## count, the selected one lit; a touch tells its place with [signal chosen],
## [constant ArmyPlaces.ALL] for the whole army
## (lib/presentation/widgets/army/army_place_bar.dart). It follows the places
## it is given by [method show_places] and the language on [method refresh].

## The player touched [param place].
signal chosen(place: int)

## Room above and below the bar, and between it and the view's sides.
const GAP := 8
const SIDE := 10
## The height the bar takes at the bottom of the view, its gaps included.
const ROOM := AbyssSegmentedTheme.HEIGHT + 2.0 * GAP

var places: ArmyPlaces
var selected: int
## The tray of segments, built again with the places.
var bar: SegmentedBar
var _margin := MarginContainer.new()


func _init(places_: ArmyPlaces, selected_ := ArmyPlaces.ALL) -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margin.add_theme_constant_override(&"margin_left", SIDE)
	_margin.add_theme_constant_override(&"margin_right", SIDE)
	_margin.add_theme_constant_override(&"margin_top", GAP)
	_margin.add_theme_constant_override(&"margin_bottom", GAP)
	add_child(_margin)
	show_places(places_, selected_)


## Shows [param places_] with [param selected_] lit.
func show_places(places_: ArmyPlaces, selected_: int) -> void:
	places = places_
	selected = selected_
	refresh()


## Builds the tray again from the places, in the language on.
func refresh() -> void:
	if places == null:
		return
	if bar != null:
		_margin.remove_child(bar)
		bar.free()
	var items: Array[SegmentItem] = []
	var shown: Array[int] = [ArmyPlaces.ALL]
	shown.append_array(places.held())
	for place in shown:
		var total := places.total_at(place)
		items.append(SegmentItem.new(place, _short(place), "%s, %s" % [_long(place),
			Texts.t(&"unitTotalCount", {"count": total})], str(total)))
	bar = SegmentedBar.new(items, selected)
	bar.chosen.connect(_on_chosen)
	_margin.add_child(bar)


## Lights the segment of [param place] without telling it.
func select(place: int) -> void:
	selected = place
	bar.select(place)


func _on_chosen(place: Variant) -> void:
	selected = place
	chosen.emit(selected)


## The name of [param place] on its segment.
static func _short(place: int) -> String:
	if place == ArmyPlaces.ALL:
		return Texts.t(&"armyPlaceAll")
	if place == KernelGarrison.STOCK_KEY:
		return Texts.t(&"unitPlaceKernel")
	return Texts.t(&"baseLevelShort", {"level": place})


## The name of [param place] as a screen reader says it.
static func _long(place: int) -> String:
	if place == ArmyPlaces.ALL:
		return Texts.t(&"armyPlaceAll")
	if place == KernelGarrison.STOCK_KEY:
		return Texts.t(&"unitPlaceKernel")
	return Texts.t(&"baseLevel", {"level": place})
