extends VectorTestCase
## Not in the Dart files: the sections of factions.json that tell how each
## personality plays, when it strikes and where it explores.

const Personality := FactionPersonality.Value


func test_every_personality_plays_as_dart_says() -> void:
	for case: Dictionary in VectorFile.new("factions").cases("traits"):
		var p := VectorInputs.value(Personality, case["personality"]) as Personality
		assert_same(_traits(p), case["out"], str(case))


static func _traits(p: Personality) -> Dictionary:
	var t := FactionTraits.of(p)
	var mix: Array = []
	for type: UnitType.Value in t.war_mix:
		mix.append([DartEnum.name_of(UnitType.Value, type), t.war_mix[type]])
	var shares: Array = []
	for turn: int in 30:
		shares.append(t.share_on(turn))
	return {
		"label": FactionPersonality.label(p),
		"cadence": t.cadence,
		"confidence": t.confidence,
		"grudgeEvery": t.grudge_every,
		"warMix": mix,
		"warShare": t.war_share,
		"conquestShare": t.conquest_share,
		"defends": t.defends,
		"postsFirst": t.posts_first,
		"rushUntil": t.rush_until,
		"rushShare": t.rush_share,
		"kernelFirst": t.kernel_first,
		"guardShare": t.guard_share,
		"explorers": t.explorers,
		"growth": VectorInputs.names(BuildingType.Value, t.growth),
		"planner": [t.planner().rehearsals, t.planner().confidence],
		"shares": shares,
	}


func test_lays_the_sieges_dart_lays() -> void:
	for case: Dictionary in VectorFile.new("factions").cases("siege"):
		var level: int = case["level"]
		var confidence: float = case["confidence"]
		var p := KernelSiege.planner_for(ArmyPlanner.new(8, confidence), level)
		assert_same([p.rehearsals, p.confidence], case["out"], str(case))
		assert_same(KernelSiege.is_hot(level), case["hot"], str(case))
	for case: Dictionary in VectorFile.new("factions").cases("siegesPerTurn"):
		var difficulty := VectorInputs.value(Difficulty.Value, case["difficulty"]) as Difficulty.Value
		assert_same(KernelSiege.won_per_turn(difficulty), case["out"], str(case))


func test_strikes_on_the_slots_dart_strikes_on() -> void:
	for case: Dictionary in VectorFile.new("factions").cases("slots"):
		var p := VectorInputs.value(Personality, case["personality"]) as Personality
		var due: Array = []
		var grudge: Array = []
		var off_slot: Array = []
		for turn: int in 48:
			if FactionWar.is_due(turn, p):
				due.append(turn)
			if FactionWar.is_grudge_slot(turn, p):
				grudge.append(turn)
			if KernelSiege.is_off_slot(turn, p):
				off_slot.append(turn)
		assert_same({"due": due, "grudge": grudge, "offSlot": off_slot}, case["out"], str(case))


func test_explores_where_dart_explores() -> void:
	for case: Dictionary in VectorFile.new("factions").cases("explorationBias"):
		var size: int = case["size"]
		var base := _position(case["base"])
		var out: Array = []
		for t: Variant in case["targets"]:
			out.append(FactionExploration.bias(base, size, size, _position(t)))
		assert_same(out, case["out"], str(case))


static func _position(xy: Variant) -> GridPosition:
	var pair: Array = xy
	var x: int = pair[0]
	var y: int = pair[1]
	return GridPosition.new(x, y)
