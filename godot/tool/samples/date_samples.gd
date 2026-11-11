class_name DateSamples
extends RefCounted
## The dates of the tests: Dart's `DateTime(year, month, day, hour,
## minute)` as the port holds a date, in milliseconds since 1970-01-01 UTC
## (domain/game/game.gd). Read in UTC where Dart reads the local time: only
## the order and the equality of two dates matter to the tests.


static func at(year: int, month: int, day: int, hour := 0, minute := 0) -> int:
	var seconds := Time.get_unix_time_from_datetime_dict({
		"year": year, "month": month, "day": day, "hour": hour, "minute": minute, "second": 0,
	})
	return seconds * 1000
