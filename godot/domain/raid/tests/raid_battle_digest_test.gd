extends TestCase
## Not in the Dart file: raids fought as the Dart rules fight them, read by
## a scratch script run with `dart run` on lib/domain (RaidBattle.fight at
## turn 12 with Random(seed), on raidPlayer). Per raid: victory, turn,
## rampart level, surprise, fight turns, monsters left, then the defenders,
## intact, wounded, dead, loot and pillage, the stocks and the units on the
## base after it, each map in its order, then the next nextInt(1000).

const HARPOONIST := UnitType.Value.HARPOONIST
const MIXED_UNITS: Dictionary[UnitType.Value, int] = {
	HARPOONIST: 12, UnitType.Value.GUARDIAN: 6, UnitType.Value.SCOUT: 3
}
const DIGESTS: Dictionary[String, String] = {
	"empty": "[false, 12, 0, false, 0, 5, {}, {}, {}, {}, {}, {algae: 300, coral: 300, ore: 300, energy: 300}, {algae: 700, coral: 700, ore: 700, energy: 700, pearl: 1000}, {}, 204]",
	"garrison": "[true, 12, 0, false, 1, 0, {harpoonist: 30}, {harpoonist: 30}, {}, {}, {algae: 0, coral: 30, ore: 20, pearl: 0}, {}, {algae: 1000, coral: 1030, ore: 1020, energy: 1000, pearl: 1000}, {harpoonist: 30}, 299]",
	"mixed7": "[false, 12, 3, true, 5, 17, {scout: 3, harpoonist: 12, guardian: 6}, {}, {scout: 3}, {harpoonist: 12, guardian: 6}, {}, {algae: 300, coral: 300, ore: 300, energy: 300}, {algae: 700, coral: 700, ore: 700, energy: 700, pearl: 1000}, {scout: 3}, 999]",
	"mixed8": "[false, 12, 3, true, 4, 19, {scout: 3, harpoonist: 12, guardian: 6}, {}, {scout: 3, harpoonist: 4, guardian: 1}, {harpoonist: 8, guardian: 5}, {}, {algae: 300, coral: 300, ore: 300, energy: 300}, {algae: 700, coral: 700, ore: 700, energy: 700, pearl: 1000}, {scout: 3, harpoonist: 4, guardian: 1}, 493]",
	"mixed11": "[false, 12, 3, true, 5, 15, {scout: 3, harpoonist: 12, guardian: 6}, {}, {scout: 3, harpoonist: 3, guardian: 2}, {harpoonist: 9, guardian: 4}, {}, {algae: 300, coral: 300, ore: 300, energy: 300}, {algae: 700, coral: 700, ore: 700, energy: 700, pearl: 1000}, {scout: 3, harpoonist: 3, guardian: 2}, 684]",
	"tech7": "[true, 12, 3, false, 12, 0, {scout: 3, harpoonist: 12, guardian: 6}, {scout: 2, harpoonist: 11}, {scout: 1, harpoonist: 1, guardian: 1}, {guardian: 5}, {algae: 0, coral: 78, ore: 42, pearl: 1}, {}, {algae: 1000, coral: 1078, ore: 1042, energy: 1000, pearl: 1001}, {scout: 3, harpoonist: 12, guardian: 1}, 569]",
	"tech8": "[false, 12, 3, false, 15, 5, {scout: 3, harpoonist: 12, guardian: 6}, {}, {scout: 3, harpoonist: 2, guardian: 4}, {harpoonist: 10, guardian: 2}, {}, {algae: 150, coral: 150, ore: 150, energy: 150}, {algae: 850, coral: 850, ore: 850, energy: 850, pearl: 1000}, {scout: 3, harpoonist: 2, guardian: 4}, 610]",
}

var _easy := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)
var _mixed := MonsterLair.new(
	MonsterDifficulty.Value.MEDIUM, 11, MonsterFamily.Value.HUNTER, MonsterFamily.Value.ARMOURED, 9
)


func test_raids_are_fought_as_dart_fights_them() -> void:
	_expect("empty", RaidSamples.raid_player(), _easy, 1)
	_expect("garrison", RaidSamples.raid_player({HARPOONIST: 30}, 0, 1), _easy, 1)
	for seed_: int in [7, 8, 11]:
		var player := RaidSamples.raid_player(MIXED_UNITS, 3, 2)
		_expect("mixed%d" % seed_, player, _mixed, seed_, 50, true)
	for seed_: int in [7, 8]:
		var player := RaidSamples.raid_player(MIXED_UNITS, 3, 2)
		var a := TechOption.Value.A
		var b := TechOption.Value.B
		for research: Array in [
			[TechBranch.Value.EXPLORER, a, a], [TechBranch.Value.RESOURCES, a, a],
			[TechBranch.Value.MILITARY, b, a],
		]:
			var branch: TechBranch.Value = research[0]
			var options: Array[TechOption.Value] = [research[1], research[2]]
			player.tech_branches[branch] = TechHelpers.researched_branch(branch, 4, options)
		_expect("tech%d" % seed_, player, _mixed, seed_)


func _expect(
	name: String, player: Player, wave: MonsterLair, seed_: int, loot_percent := 100, surprise := false
) -> void:
	var random := DartRandom.new(seed_)
	var r := RaidBattle.fight(player, wave, 12, random, loot_percent, surprise)
	var stocks := {}
	for type: ResourceType.Value in player.resources:
		stocks[type] = player.resources[type].amount
	var fields := PackedStringArray([
		r.victory, r.turn, r.rampart_level, r.surprise, r.fight.turn_count,
		r.fight.final_monster_count, _units(r.defenders), _units(r.survivors_intact),
		_units(r.wounded), _units(r.dead), _stocks(r.loot), _stocks(r.pillaged), _stocks(stocks),
		_units(player.unit_counts_on_level(1)), random.next_int(1000),
	].map(str))
	assert_eq("[%s]" % ", ".join(fields), DIGESTS[name], name)


func _units(map: Dictionary) -> String:
	return _named(UnitType.Value, map)


func _stocks(map: Dictionary) -> String:
	return _named(ResourceType.Value, map)


## A map as Dart prints `{name: value, ...}`, in its order.
func _named(enumeration: Dictionary, map: Dictionary) -> String:
	var pairs := PackedStringArray()
	for key: int in map:
		pairs.append("%s: %d" % [DartEnum.name_of(enumeration, key), map[key]])
	return "{%s}" % ", ".join(pairs)
