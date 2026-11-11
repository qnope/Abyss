class_name SaveList
extends RefreshingPanel
## The saves in progress then the finished ones, each section under its
## header, in one scroll view centred on wide screens
## (lib/presentation/widgets/save/save_list.dart). The game in progress played
## last glows: the one a player most likely resumes. It tells what the player
## does with a game; it opens and deletes nothing.

## The player touched [param game]'s card.
signal game_opened(game: Game)
## The player chose to delete [param game], from its card's options.
signal delete_requested(game: Game)

const MAX_WIDTH := 560.0
const GUTTER := 16
const GAP := 10
const BOTTOM := 24

var _column := VBoxContainer.new()
var _cards: Dictionary[Game, SaveCard] = {}
var _headers: Array[SaveSectionHeader] = []


## The list of [param sections], dated against [param now] (milliseconds since
## 1970 UTC).
func _init(sections: SaveSections, now: int) -> void:
	super()
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var frame := MarginContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_theme_constant_override(&"margin_bottom", BOTTOM)
	_column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_column.add_theme_constant_override(&"separation", GAP)
	_column.custom_minimum_size.x = MAX_WIDTH
	var recent := sections.most_recent_in_progress()
	_section(&"saveInProgress", sections.in_progress, now, recent)
	_section(&"saveFinished", sections.finished, now, recent)
	frame.add_child(_column)
	scroll.add_child(frame)
	add_child(scroll)
	resized.connect(func() -> void: fit(size))


## The card of [param game], null if it is not listed.
func card_of(game: Game) -> SaveCard:
	return _cards.get(game)


## Every card, in the order shown.
func cards() -> Array[SaveCard]:
	return _cards.values()


## Keeps the column to its [constant MAX_WIDTH] and the sides to the gutter.
func fit(area: Vector2) -> void:
	_column.custom_minimum_size.x = clampf(area.x - 2.0 * GUTTER, 0.0, MAX_WIDTH)


func refresh() -> void:
	for header in _headers:
		header.refresh()


func _section(key: StringName, games: Array[Game], now: int, recent: Game) -> void:
	if games.is_empty():
		return
	var header := SaveSectionHeader.new(key)
	_headers.append(header)
	_column.add_child(header)
	for game in games:
		var card := SaveCard.new(SaveSummary.of(game), now, game == recent)
		card.tapped.connect(game_opened.emit.bind(game))
		card.delete_requested.connect(delete_requested.emit.bind(game))
		_cards[game] = card
		_column.add_child(card)
