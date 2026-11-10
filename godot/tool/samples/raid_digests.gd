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


## The sum of the values of `map`.
static func sum(map: Dictionary) -> int:
	var total := 0
	for value: int in map.values():
		total += value
	return total


static func _null_text(text: String) -> String:
	return "null" if text == "<null>" else text
