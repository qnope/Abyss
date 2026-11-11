class_name SaveSections
extends RefCounted
## lib/domain/game/save_sections.dart: the saves split into games in
## progress and finished games, each latest played first.

## Read-only, as Dart's `List.unmodifiable`.
var in_progress: Array[Game]
var finished: Array[Game]


func _init(in_progress_: Array[Game], finished_: Array[Game]) -> void:
	in_progress = in_progress_
	finished = finished_


static func of(games: Array[Game]) -> SaveSections:
	var in_progress_: Array[Game] = []
	var finished_: Array[Game] = []
	for game: Game in games:
		if SaveOutcome.is_finished(SaveOutcome.of(game.status)):
			finished_.append(game)
		else:
			in_progress_.append(game)
	return SaveSections.new(_latest_first(in_progress_), _latest_first(finished_))


func is_empty() -> bool:
	return in_progress.is_empty() and finished.is_empty()


## Every save, in progress or finished.
func count() -> int:
	return in_progress.size() + finished.size()


## The game a "continue" shortcut resumes, if any is still played.
func most_recent_in_progress() -> Game:
	return null if in_progress.is_empty() else in_progress[0]


static func _latest_first(games: Array[Game]) -> Array[Game]:
	DartSort.sort(games, func(a: Game, b: Game) -> int:
		return DartSort.compare_ints(b.last_played_at(), a.last_played_at()))
	games.make_read_only()
	return games
