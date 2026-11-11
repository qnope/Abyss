class_name TurnStates
extends RefCounted
## The state of a player that the digest test of the whole games compares
## after each end of turn (TurnDigests): `stocks|units by level|building
## levels|research|revealed on 1.2.3|raids|kraken waves|orders|event|attacks
## on it|kernel|posts|intel|objectives|history|fallen`.


static func state(game: Game, p: Player) -> String:
	var stocks := PackedStringArray()
	for r: GameResource in p.resources.values():
		stocks.append(str(r.amount))
	var by_level := ""
	for level: int in p.units_per_level:
		by_level += "%d[%s]" % [level, units(p.unit_counts_on_level(level))]
	var levels := ""
	for b: Building in p.buildings.values():
		levels += str(b.level)
	var tech := PackedStringArray()
	for s: TechBranchState in p.tech_branches.values():
		tech.append("%d%d" % [1 if s.unlocked else 0, s.research_level])
	var seen := PackedStringArray()
	for level: int in [1, 2, 3]:
		seen.append(str(p.revealed_cells_on_level(level).size()))
	var attacks := PackedStringArray()
	for a: AnnouncedAttack in p.raid_state.attacks:
		attacks.append("%s:%d:%d" % [a.attacker_id, a.arrival_turn, a.fight_seed])
	var intel := PackedStringArray()
	for id: String in p.intel():
		intel.append("%s@%d" % [id, p.intel()[id].turn])
	var completed := "null"
	if p.saved_objective_state != null:
		completed = str(p.saved_objective_state.completed.size())
	return "|".join([
		" ".join(stocks), by_level, levels, ".".join(tech), ".".join(seen), _raids(p), _waves(p),
		"%d.%d" % [p.pending_explorations.size(), p.pending_reinforcements.size()], _event(p),
		",".join(attacks), "k%d%s" % [KernelGarrison.kernel_level_of(p), "H" if game.is_volcanic_kernel_captured_by(p.id) else ""],
		"p" + _posts(game, p), "i" + ",".join(intel), completed, "h%d" % p.history_entries.size(),
		"F" if p.has_fallen() else "",
	])


## `name:count` of the units of `map`, in its order.
static func units(map: Dictionary) -> String:
	return HistoryDigests.counts(map, UnitType.Value)


## RaidDigests.wave, or `-`.
static func wave(lair: MonsterLair) -> String:
	return "-" if lair == null else RaidDigests.wave(lair)


static func _raids(p: Player) -> String:
	var s := p.raid_state
	return "%d.%d.%d.%d.%d.%s.%s" % [
		s.noise, s.total_noise, s.lost_in_a_row, s.raids_repelled, s.raids_lost, wave(s.incoming),
		WarDigests.text(s.arrival_turn),
	]


static func _waves(p: Player) -> String:
	var v := p.volcano_state
	return "%s.%d.%d" % [WarDigests.text(v.arrival_turn), v.waves_repelled, v.levels_lost]


static func _event(p: Player) -> String:
	var ev := p.event_state
	return "%s%s.%s.%s" % [
		_name(ev.active), "H" if ev.heating else "", _name(ev.pending), WarDigests.text(ev.next_draw_turn)
	]


static func _name(type: Variant) -> String:
	if type == null:
		return "null"
	var event: RandomEventType.Value = type
	return DartEnum.name_of(RandomEventType.Value, event)


## The levels of the posts `p` holds, level by level, cell by cell.
static func _posts(game: Game, p: Player) -> String:
	var posts := ""
	for level: int in game.levels:
		for c: MapCell in game.levels[level].cells:
			if c.transition_base != null and c.transition_base.captured_by == p.id:
				posts += str(level)
	return posts
