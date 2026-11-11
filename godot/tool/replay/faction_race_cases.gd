class_name FactionRaceCases
extends RefCounted
## test/domain/faction/faction_race_test.dart, a case per personality: its
## six games of up to 200 turns take 35 to 95 s in Godot.

const PREFIX := "faction-race-"


## The names of the cases, `faction-race-<personality>` by its Dart name.
static func names() -> Array[String]:
	var all: Array[String] = []
	for personality: FactionPersonality.Value in FactionPersonality.Value.values():
		all.append(PREFIX + DartEnum.name_of(FactionPersonality.Value, personality))
	return all


## 'left alone, <label> tames the volcano before 200', for the case `name`.
static func run(name: String) -> PackedStringArray:
	var personality: FactionPersonality.Value = DartEnum.by_name(FactionPersonality.Value, name.trim_prefix(PREFIX))
	var label := FactionPersonality.label(personality)
	var checks := CaseChecks.new()
	var winners: Array[Game] = []
	for seed_: int in range(1, 7):
		var game := FactionRace.play_lone_faction(personality, seed_, 200)
		if VictoryChecker.winner_of(game) != null:
			winners.append(game)

	checks.expect(winners.size() >= 5, "%s won %d games of 6, not 5 or more" % [label, winners.size()])
	for game: Game in winners:
		var winner := VictoryChecker.winner_of(game)
		checks.expect(winner.name == label, "%s won, not %s" % [winner.name, label])
		var kernel := winner.buildings[BuildingType.Value.VOLCANIC_KERNEL].level
		checks.expect(kernel == 10, "%s has its kernel at %d, not 10" % [label, kernel])
		# The human did nothing, so the faction's win is the human's defeat.
		game.status = GameStatus.Value.PLAYING
		var status: Variant = VictoryChecker.check(game)
		var defeated: bool = status == GameStatus.Value.DEFEAT
		checks.expect(defeated, "the human's status is %s, not defeat" % status)
	return checks.failures
