class_name RelativeDate
extends RefCounted
## lib/presentation/extensions/relative_date_extensions.dart: how long ago a
## date was, in the player's language: "à l'instant", "il y a 5 min",
## "il y a 2 h" earlier the same day, "hier", then a short date such as
## "5 oct.", with the year when it is not the one of now.
##
## Dates are milliseconds since 1970-01-01 UTC, as the saves keep them; the
## days are those of a time zone given as its offset from UTC in minutes,
## the system's by default. One offset serves both dates, so a date on the
## other side of a daylight-saving change can be off by an hour around
## midnight, which Dart's `toLocal` would not be.

const _MINUTE := 60000
const _HOUR := 3600000
const _DAY := 86400000
## The keys of the months in the `saveMonth` text, from January.
const _MONTHS: Array[String] = [
	"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec",
]


## `date.relativeTo(l10n, now)`, both in milliseconds since 1970 UTC.
static func relative_to(date_ms: int, now_ms: int, offset_minutes: int = local_offset_minutes()) -> String:
	var elapsed := now_ms - date_ms
	var minutes := DartMath.trunc_div(elapsed, _MINUTE)
	var hours := DartMath.trunc_div(elapsed, _HOUR)
	if minutes < 1:
		return Texts.t(&"saveJustNow")
	if hours < 1:
		return Texts.t(&"saveMinutesAgo", {"minutes": minutes})
	var date := _local(date_ms, offset_minutes)
	var today := _local(now_ms, offset_minutes)
	var day := DartMath.trunc_div(date_ms + offset_minutes * _MINUTE, _DAY)
	var today_day := DartMath.trunc_div(now_ms + offset_minutes * _MINUTE, _DAY)
	if day == today_day:
		return Texts.t(&"saveHoursAgo", {"hours": hours})
	if day == today_day - 1:
		return Texts.t(&"saveYesterday")
	var month_number: int = date["month"]
	var month := Texts.t(&"saveMonth", {"month": _MONTHS[month_number - 1]})
	var args := {"day": date["day"], "month": month, "year": date["year"]}
	if date["year"] == today["year"]:
		return Texts.t(&"saveShortDate", args)
	return Texts.t(&"saveShortDateWithYear", args)


## The offset of the system's time zone from UTC, in minutes.
static func local_offset_minutes() -> int:
	var zone: Dictionary = Time.get_time_zone_from_system()
	var bias: int = zone["bias"]
	return bias


## The year, month and day of `ms` in the time zone `offset_minutes` east of UTC.
static func _local(ms: int, offset_minutes: int) -> Dictionary:
	return Time.get_date_dict_from_unix_time(DartMath.trunc_div(ms + offset_minutes * _MINUTE, 1000))
