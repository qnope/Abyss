class_name DefeatAnalysis
extends RefCounted
## lib/domain/game/defeat_analysis.dart: why the base fell to the raids,
## read from the history.

## The raids lost in a row, oldest first.
var raids: Array[LostRaid]
var advice: DefeatAdvice.Value
## Harpoonists alone that would have beaten the last wave (an int); null
## when even the most the guide advises would not have.
var harpoonists_needed: Variant


func _init(raids_: Array[LostRaid], advice_: DefeatAdvice.Value, harpoonists_needed_: Variant = null) -> void:
	raids = raids_
	advice = advice_
	harpoonists_needed = harpoonists_needed_


## The analysis of the human's fall, null when no raid was lost.
static func of(game: Game) -> DefeatAnalysis:
	var player := game.human_player()
	var lost: Array[RaidEntry] = []
	for i: int in range(player.history_entries.size() - 1, -1, -1):
		var e := player.history_entries[i]
		if not e is RaidEntry or (e as RaidEntry).surprise:
			continue
		if (e as RaidEntry).victory or lost.size() == DefeatChecker.LOST_RAIDS_LIMIT:
			break
		lost.insert(0, e as RaidEntry)
	if lost.is_empty():
		return null
	var raids_: Array[LostRaid] = []
	var unarmed := true
	for e: RaidEntry in lost:
		var defenders := 0
		for count: int in e.defenders.values():
			defenders += count
		raids_.append(LostRaid.new(e.turn, e.wave, defenders))
		unarmed = unarmed and defenders == 0
	if unarmed:
		return DefeatAnalysis.new(raids_, DefeatAdvice.Value.RAISE_AN_ARMY)
	var last: LostRaid = raids_.back()
	var needed: Variant = RaidDefenceAdvisor.harpoonists_alone(player, last.wave)
	var enough: bool = needed != null and last.defenders >= needed
	var advice_ := DefeatAdvice.Value.COUNTER_THE_FAMILIES if enough else DefeatAdvice.Value.MORE_DEFENDERS
	return DefeatAnalysis.new(raids_, advice_, needed)
