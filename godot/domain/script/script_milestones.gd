class_name ScriptMilestones
extends RefCounted
## lib/domain/script/script_milestones.dart: first turn each step of the
## road to the volcano was reached, every raid of the game, and the
## guardians' strike back at the first Faille. Its second type is
## ScriptRaid. The turns are ints or null, `leviathan_held` a bool or null.

var faille_captured: Variant = null
var cheminee_captured: Variant = null
var kernel_captured: Variant = null
## Turn the guardians struck the first Faille back, if they did, and
## whether it held.
var leviathan_struck: Variant = null
var leviathan_held: Variant = null
var raids: Array[ScriptRaid] = []
var waves: Array[ScriptRaid] = []


## Notes the steps `player_id` (a String; the human when null) has
## reached in `game` by the end of turn `turn`.
func observe(game: Game, turn: int, player_id: Variant = null) -> void:
	var id: String = player_id if player_id != null else game.human_player_id
	var held := game.captured_base_types_of(id)
	if held.has(TransitionBaseType.Value.FAILLE) and faille_captured == null:
		faille_captured = turn
	if held.has(TransitionBaseType.Value.CHEMINEE) and cheminee_captured == null:
		cheminee_captured = turn
	if game.is_volcanic_kernel_captured_by(id) and kernel_captured == null:
		kernel_captured = turn


## Notes the kraken wave of `report`, if a turn ended on one.
func observe_wave(report: VolcanoReport) -> void:
	if report != null:
		waves.append(ScriptRaid.of_wave(report))


## Notes the guardians' strike `report`, if a turn ended on one.
func observe_leviathan(report: FactionAttackReport) -> void:
	if report == null:
		return
	leviathan_struck = report.entry.turn
	leviathan_held = report.outcome() == AttackOutcome.Value.REPELLED


func to_json() -> Dictionary:
	return {
		"failleCaptured": faille_captured,
		"chemineeCaptured": cheminee_captured,
		"kernelCaptured": kernel_captured,
		"leviathanStruck": leviathan_struck,
		"leviathanHeld": leviathan_held,
		"raids": raids.map(func(r: ScriptRaid) -> Dictionary: return r.to_json()),
		"waves": waves.map(func(r: ScriptRaid) -> Dictionary: return r.to_json()),
	}
