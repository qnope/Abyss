class_name FactionKernelGuard
extends RefCounted
## lib/domain/faction/faction_kernel_guard.dart: what a faction does for the
## kernel it holds: when its garrison would lose to the next kraken wave,
## half of the fighters idling on its base go down to reinforce it. The
## conquest strategy only sends the units it has just recruited, which leaves
## a big home army useless while the kernel falls. What goes down stays
## there, so the base keeps what holds the raid announced, or the one its
## noise will bring next: a lost kraken wave costs a kernel level, three lost
## raids the whole faction.

## Share of the home fighters sent down to the kernel in one turn.
const SHARE := 0.5


static func play(turn: ScriptTurn, share := SHARE) -> void:
	var me := turn.player
	if not turn.game.is_volcanic_kernel_captured_by(me.id):
		return
	var level := KernelGarrison.kernel_level_of(me)
	if level < 1 or level >= 10:
		return
	var wave := VolcanoWaveFactory.from_kernel_level(level, _monster_percent(turn))
	var waves := func() -> Array[Combatant]: return CombatantBuilder.monster_combatants_from(wave)
	var rampart := func() -> Array[Combatant]: return [MagmaRampart.combatant_for(level)] as Array[Combatant]
	if FactionWar.planner().wins(_guard_of(me), waves, ExpeditionMoves.defence_boost(turn), rampart):
		return
	var sent := _spare(turn, share)
	if not ExpeditionMoves.descend(turn, 1, sent):
		return
	ExpeditionMoves.descend(turn, 2, sent)


## `share` of the home fighters, less what the base needs to hold the raid
## announced, or else every one the noise can raise next (_next_raids).
static func _spare(turn: ScriptTurn, share: float) -> Dictionary[UnitType.Value, int]:
	var home := ExpeditionMoves.fighters_on(turn, 1)
	home.erase(UnitType.Value.ABYSS_ADMIRAL)
	var incoming := turn.player.raid_state.incoming
	var raids: Array[MonsterLair] = [incoming]
	if incoming == null:
		raids = _next_raids(turn)
	for part: float in [share, share / 2, 0.1]:
		var sent: Dictionary[UnitType.Value, int] = {}
		for type: UnitType.Value in home:
			sent[type] = floori(home[type] * part)
		var kept: Dictionary[UnitType.Value, int] = {}
		for type: UnitType.Value in home:
			kept[type] = home[type] - sent[type]
		if raids.all(func(raid: MonsterLair) -> bool: return _holds(turn, kept, raid)):
			return sent
	return {}


static func _holds(turn: ScriptTurn, kept: Dictionary[UnitType.Value, int], raid: MonsterLair) -> bool:
	return FactionWar.planner().wins(
		kept,
		func() -> Array[Combatant]: return CombatantBuilder.monster_combatants_from(raid),
		ExpeditionMoves.defence_boost(turn),
		_rampart(turn.player),
	)


## The waves the noise of `turn`'s player can raise next, one for each pair
## of families, before the share of the base's own strength (RaidResolver),
## which the units kept home are sized to beat anyway.
static func _next_raids(turn: ScriptTurn) -> Array[MonsterLair]:
	return RaidWaveFactory.every_from_total_noise(turn.player.raid_state.total_noise, _monster_percent(turn))


static func _monster_percent(turn: ScriptTurn) -> int:
	return Difficulty.monster_percent_for(turn.game.difficulty(), true)


## `() => [CoralCitadelRampart.combatantOf(me.buildings)!]`, or an invalid
## Callable for null when the base has no rampart.
static func _rampart(me: Player) -> Callable:
	if CoralCitadelRampart.combatant_of(me.buildings) == null:
		return Callable()
	return func() -> Array[Combatant]:
		return [CoralCitadelRampart.combatant_of(me.buildings)] as Array[Combatant]


## The garrison and the fighters waiting on the volcano level.
static func _guard_of(me: Player) -> Dictionary[UnitType.Value, int]:
	var guard := KernelGarrison.of(me)
	var units := me.units_on_level(KernelGarrison.VOLCANO_LEVEL)
	for t: UnitType.Value in units:
		var u: Unit = units[t]
		if u.count > 0 and t != UnitType.Value.SCOUT and t != UnitType.Value.ABYSS_ADMIRAL:
			guard[t] = guard.get(t, 0) + u.count
	return guard
