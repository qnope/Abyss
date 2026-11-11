extends TextsTestCase
## test/presentation/extensions/relative_date_extensions_test.dart. Dates are
## written as "year-month-day hour:minute" in the time zone the test asks
## for, UTC unless it says otherwise.

const MINUTE := 60000
const HOUR := 3600000

## 2026-10-10 15:30.
var now := _at(2026, 10, 10, 15, 30)


func _at(year: int, month: int, day: int, hour := 0, minute := 0, offset := 0) -> int:
	var seconds := Time.get_unix_time_from_datetime_dict({
		"year": year, "month": month, "day": day, "hour": hour, "minute": minute, "second": 0,
	})
	return seconds * 1000 - offset * MINUTE


func _say(date: int, locale := "fr", at := now, offset := 0) -> String:
	TranslationServer.set_locale(locale)
	return RelativeDate.relative_to(date, at, offset)


func test_less_than_a_minute_ago_is_just_now() -> void:
	assert_eq(_say(now), "à l'instant")
	assert_eq(_say(now - 59000), "à l'instant")


func test_a_date_slightly_in_the_future_is_just_now() -> void:
	assert_eq(_say(now + 3 * MINUTE), "à l'instant")


func test_counts_the_whole_minutes_elapsed() -> void:
	assert_eq(_say(now - MINUTE), "il y a 1 min")
	assert_eq(_say(now - 5 * MINUTE - 50000), "il y a 5 min")
	assert_eq(_say(now - 59 * MINUTE), "il y a 59 min")


func test_minutes_are_counted_across_midnight() -> void:
	assert_eq(_say(_at(2026, 10, 9, 23, 50), "fr", _at(2026, 10, 10, 0, 10)), "il y a 20 min")


func test_counts_the_whole_hours_elapsed_earlier_the_same_day() -> void:
	assert_eq(_say(now - HOUR), "il y a 1 h")
	assert_eq(_say(now - 2 * HOUR - 59 * MINUTE), "il y a 2 h")
	assert_eq(_say(_at(2026, 10, 10)), "il y a 15 h")


func test_any_time_of_the_previous_day_is_yesterday() -> void:
	assert_eq(_say(_at(2026, 10, 9, 23, 59)), "hier")
	assert_eq(_say(_at(2026, 10, 9)), "hier")


func test_yesterday_crosses_months_and_years() -> void:
	assert_eq(_say(_at(2026, 9, 30, 20), "fr", _at(2026, 10, 1, 8)), "hier")
	assert_eq(_say(_at(2025, 12, 31, 20), "fr", _at(2026, 1, 1, 8)), "hier")


func test_older_dates_show_the_day_and_short_month_of_this_year() -> void:
	assert_eq(_say(_at(2026, 10, 8, 12)), "8 oct.")
	assert_eq(_say(_at(2026, 1, 1)), "1 janv.")


func test_another_year_adds_the_year() -> void:
	assert_eq(_say(_at(2025, 10, 5)), "5 oct. 2025")


func test_uses_the_french_short_month_names() -> void:
	var months := ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."]
	for month in range(1, 13):
		assert_eq(_say(_at(2024, month, 3)), "3 %s 2024" % months[month - 1])


func test_in_english() -> void:
	assert_eq(_say(now, "en"), "just now")
	assert_eq(_say(now - 5 * MINUTE, "en"), "5 min ago")
	assert_eq(_say(now - 2 * HOUR, "en"), "2 h ago")
	assert_eq(_say(_at(2026, 10, 9, 8), "en"), "yesterday")
	assert_eq(_say(_at(2026, 10, 8, 12), "en"), "Oct 8")
	assert_eq(_say(_at(2025, 1, 5), "en"), "Jan 5, 2025")


func test_in_spanish() -> void:
	assert_eq(_say(now, "es"), "ahora mismo")
	assert_eq(_say(now - 5 * MINUTE, "es"), "hace 5 min")
	assert_eq(_say(now - 2 * HOUR, "es"), "hace 2 h")
	assert_eq(_say(_at(2026, 10, 9, 8), "es"), "ayer")
	assert_eq(_say(_at(2026, 1, 8, 12), "es"), "8 ene")
	assert_eq(_say(_at(2025, 12, 5), "es"), "5 dic 2025")


func test_the_days_are_the_days_of_the_time_zone() -> void:
	# 23:30 UTC on the 9th is 01:30 on the 10th at UTC+2: earlier today.
	var date := _at(2026, 10, 9, 23, 30)
	assert_eq(_say(date, "fr", now, 0), "hier")
	assert_eq(_say(date, "fr", now, 120), "il y a 16 h")
	# 01:00 UTC on the 10th is 22:00 on the 9th at UTC-3.
	assert_eq(_say(_at(2026, 10, 10, 1), "fr", now, -180), "hier")


func test_the_local_offset_is_the_one_of_the_system() -> void:
	var bias: int = Time.get_time_zone_from_system()["bias"]
	assert_eq(RelativeDate.local_offset_minutes(), bias)
	assert_eq(RelativeDate.relative_to(now, now), "à l'instant")
