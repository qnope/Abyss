class_name ThreatWarningsCase
extends UiTestCase
## What the tests of the threat warnings share: a game of "Nemo" at turn 12,
## the wave of a raid, and the warnings of [ThreatWarnings] kept in the window.

var _game: Game
var _human: Player


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.turn = 12
	_human = _game.human_player()


func _wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 40, MonsterFamily.Value.SWARM)


## [param warning] in the window, freed with it; null when there is none.
func _kept(warning: Control) -> Control:
	if warning != null:
		mount(warning)
	return warning


func _of() -> Array[Control]:
	var found := ThreatWarnings.of(_game, _human)
	for warning in found:
		mount(warning)
	return found


func _raid() -> RaidDueWarning:
	return _kept(ThreatWarnings.raid(_game, _human)) as RaidDueWarning


func _predators() -> RaidDueWarning:
	return _kept(ThreatWarnings.predators(_game, _human)) as RaidDueWarning


func _volcano() -> VolcanoDueWarning:
	return _kept(ThreatWarnings.volcano(_game, _human)) as VolcanoDueWarning


## The warning of the guardians in the scene [param war].
func _guardians(war: PostWar) -> LeviathanDueWarning:
	return _kept(ThreatWarnings.leviathan(war.game, war.human())) as LeviathanDueWarning


## The scene at the turn the guardians strike, or the one before.
func _strike(before := false) -> PostWar:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war) - (1 if before else 0))
	return war
