class_name RaidDigests
extends RefCounted
## The short texts the digest tests of the raids and of the volcano compare
## with what a scratch Dart script printed on the same games, and the army
## they give the players first. Each text writes what the Dart script
## writes, in its order.


## The human of `game` ("human") gets 15 harpoonists, 4 guardians, a Coral
## Citadel 2 and a headquarters 3; every faction 8 harpoonists.
static func arm_for_raids(game: Game) -> void:
	for player: Player in game.players.values():
		var units := player.units_on_level(1)
		if player.id != "human":
			units[UnitType.Value.HARPOONIST].count = 8
			continue
		units[UnitType.Value.HARPOONIST].count = 15
		units[UnitType.Value.GUARDIAN].count = 4
		var citadel := BuildingType.Value.CORAL_CITADEL
		var headquarters := BuildingType.Value.HEADQUARTERS
		player.buildings[citadel] = Building.new(citadel, 2)
		player.buildings[headquarters] = Building.new(headquarters, 3)


## arm_for_raids, then the kernel of the human at level 3 guarded by 12
## guardians and 20 dome breakers, those of the factions at level 2 by 4
## guardians.
static func arm_for_volcano(game: Game) -> void:
	arm_for_raids(game)
	for player: Player in game.players.values():
		var human := player.id == "human"
		player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 3 if human else 2
		var stock := KernelGarrison.stock_of(player)
		stock[UnitType.Value.GUARDIAN].count = 12 if human else 4
		if human:
			stock[UnitType.Value.DOME_BREAKER].count = 20


## `difficulty/family/unitCount/secondFamily/secondCount`, a missing family
## as "null".
static func wave(lair: MonsterLair) -> String:
	var fields: Array = RaidInputs.wave(lair)
	return "/".join(PackedStringArray(fields.map(str).map(_null_text)))


## `turn V|L dead wounded loot pillaged fight-turns`, the maps summed.
static func report(r: RaidReport) -> String:
	return "%d %s %d %d %d %d %d" % [
		r.turn, "V" if r.victory else "L", sum(r.dead), sum(r.wounded), sum(r.loot),
		sum(r.pillaged), r.fight.turn_count,
	]


## `noise total lostInARow repelled lost incoming | stocks | units on the
## base`, the stocks and the units in their order.
static func raid_state(player: Player) -> String:
	var s := player.raid_state
	var stocks := PackedStringArray()
	for stock: GameResource in player.resources.values():
		stocks.append(str(stock.amount))
	var units := PackedStringArray()
	for unit: Unit in player.units_on_level(1).values():
		units.append(str(unit.count))
	return "%d %d %d %d %d %s | %s | %s" % [
		s.noise, s.total_noise, s.lost_in_a_row, s.raids_repelled, s.raids_lost,
		s.is_incoming(), " ".join(stocks), " ".join(units),
	]


## `turn V|L kernel-level krakens dead wounded fight-turns`, the maps summed.
static func volcano_report(r: VolcanoReport) -> String:
	return "%d %s %d %d %d %d %d" % [
		r.turn, "V" if r.victory else "L", r.kernel_level, r.wave.unit_count, sum(r.dead),
		sum(r.wounded), r.fight.turn_count,
	]


## `repelled lost incoming arrival kernel-level | garrison stock | raids
## repelled lost`, the stock in its order.
static func volcano_state(player: Player) -> String:
	var v := player.volcano_state
	var stock := PackedStringArray()
	for unit: Unit in KernelGarrison.stock_of(player).values():
		stock.append(str(unit.count))
	return "%d %d %s %s %d | %s | %d %d" % [
		v.waves_repelled, v.levels_lost, v.is_incoming(), _null_text(str(v.arrival_turn)),
		KernelGarrison.kernel_level_of(player), " ".join(stock),
		player.raid_state.raids_repelled, player.raid_state.raids_lost,
	]


## The sum of the values of `map`.
static func sum(map: Dictionary) -> int:
	var total := 0
	for value: int in map.values():
		total += value
	return total


static func _null_text(text: String) -> String:
	return "null" if text == "<null>" else text
