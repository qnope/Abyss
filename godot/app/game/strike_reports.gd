class_name StrikeReports
extends RefCounted
## The strike played on the map before the report of a fight opens
## (lib/presentation/screens/game/game_screen_fight_actions.dart): the report is
## the [param then] of the strike, and opens at once when there is nothing to
## play it on.


## Plays [param attack] with [param strike] (a Callable taking the strike and
## what to do then, [method MapController.strike]), then calls [param then].
static func play(strike: Callable, attack: MapStrike, then: Callable) -> void:
	if strike.is_valid():
		strike.call(attack, then)
	else:
		then.call()
