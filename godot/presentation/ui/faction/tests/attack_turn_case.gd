class_name AttackTurnCase
extends UiTestCase
## The turn of the tests of the attacks of the factions in the end-of-turn
## summary: the results to show and the section they build.

const Harpoonist := UnitType.Value.HARPOONIST
const KERNEL := AttackHeldKernelAction.KERNEL_CODE

var _answers: Array = []


## The result of the turn the rival attacks the bare base (or the wall of
## [param defenders]) and fights it, with the personality of a faction.
func _fought(defenders: Dictionary[UnitType.Value, int] = {}) -> TurnResult:
	var game := AssaultSamples.announce_game()
	game.saved_factions.assign([FactionPersonality.Value.ANGLER_CULT])
	AssaultSamples.station(game.human_player(), defenders)
	AssaultSamples.announce().execute(game, AssaultSamples.rival_of(game))
	var done: EndTurnActionResult = EndTurnAction.new(DartRandom.new(1), false).execute(game, game.human_player())
	return done.turn_result


## The result of a turn whose one attack is [param entry]'s, by [param attacker].
func _reported(entry: BaseAssaultEntry, attacker := "Nacre") -> TurnResult:
	var report := FactionAttackReport.new("nacre", attacker, null, entry)
	return TurnResult.new([], 14, 15, false, [], {}, [], [], null, null, null, null, null, null, null, null, [], [], [report])


func _show(result: TurnResult) -> TurnSummary:
	var dialog := TurnSummary.new(result)
	dialog.closed.connect(_answers.append)
	modals().open(dialog)
	return dialog


func _section(result: TurnResult) -> AttackTurnSection:
	return find_type("AttackTurnSection", _show(result))[0] as AttackTurnSection


func _attack(victory: bool, post: Variant = null, kernel: Variant = null, lost := {}, destroyed := true) -> BaseAssaultEntry:
	var lost_with: Dictionary[UnitType.Value, int] = {}
	lost_with.assign(lost)
	var dead: Dictionary[UnitType.Value, int] = {Harpoonist: 2}
	return HistorySamples.base_assault_entry(victory, true, post, kernel, lost_with, dead, destroyed)
