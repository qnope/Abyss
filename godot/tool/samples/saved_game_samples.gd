class_name SavedGameSamples
extends RefCounted
## Saved games for the tests of the menus (test/helpers/load_game_harness.dart:
## savedGame): a single-player game of a given turn, status and last played
## date, on a map of a fixed seed.

const HOUR := 3600000


## The time the sample games are told against: noon on 2026-10-10 UTC.
static func now() -> int:
	return int(Time.get_unix_time_from_datetime_dict(
		{"year": 2026, "month": 10, "day": 10, "hour": 12, "minute": 0, "second": 0})) * 1000


## A game of the player [param player_name], last played [param hours_ago]
## before [method now].
static func game(player_name: String, turn := 1, status := GameStatus.Value.PLAYING,
		hours_ago := 2, difficulty := Difficulty.Value.NORMAL) -> Game:
	var made := GameFactory.new_single_player(player_name, 1, difficulty)
	made.turn = turn
	made.status = status
	made.saved_last_played_at = now() - hours_ago * HOUR
	return made
