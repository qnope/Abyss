extends TestCase
## Not in the Dart files, which read VolcanoBattle through the resolver:
## kraken waves fought as the Dart rules fight them, read by a scratch
## script run with `dart run` on lib/domain (VolcanoBattle.fight at turn 30
## with Random(seed), the wave of VolcanoWaveFactory.fromKernelLevel). Per
## wave: victory, turn, kernel level, kernelLevelAfter, krakens, fight
## turns, krakens left, defenders, intact, wounded, dead, the kernel level
## and the garrison's whole stock after it, then the next nextInt(1000).

const GUARDIAN := UnitType.Value.GUARDIAN
const DOME_BREAKER := UnitType.Value.DOME_BREAKER
const DIGESTS: Dictionary[String, String] = {
	"empty": "[false, 30, 3, 2, 6, 3, 6, {}, {}, {}, {}, 2, {scout: 0, harpoonist: 0, guardian: 0, domeBreaker: 0, abyssAdmiral: 0, saboteur: 0}, 377]",
	"level0": "[false, 30, 0, -1, 2, 2, 2, {guardian: 2}, {}, {guardian: 1}, {guardian: 1}, 0, {scout: 0, harpoonist: 0, guardian: 1, domeBreaker: 0, abyssAdmiral: 0, saboteur: 0}, 700]",
	"garrison3": "[true, 30, 2, 2, 4, 6, 0, {harpoonist: 4, guardian: 5, domeBreaker: 8}, {harpoonist: 1, domeBreaker: 3}, {harpoonist: 2, guardian: 1, domeBreaker: 1}, {harpoonist: 1, guardian: 4, domeBreaker: 4}, 2, {scout: 0, harpoonist: 3, guardian: 1, domeBreaker: 4, abyssAdmiral: 0, saboteur: 0}, 140]",
	"garrison4": "[true, 30, 2, 2, 4, 7, 0, {harpoonist: 4, guardian: 5, domeBreaker: 8}, {harpoonist: 1, domeBreaker: 5}, {harpoonist: 1, guardian: 4}, {harpoonist: 2, guardian: 1, domeBreaker: 3}, 2, {scout: 0, harpoonist: 2, guardian: 4, domeBreaker: 5, abyssAdmiral: 0, saboteur: 0}, 106]",
	"garrison5": "[true, 30, 2, 2, 4, 7, 0, {harpoonist: 4, guardian: 5, domeBreaker: 8}, {domeBreaker: 6}, {harpoonist: 1, guardian: 3}, {harpoonist: 3, guardian: 2, domeBreaker: 2}, 2, {scout: 0, harpoonist: 1, guardian: 3, domeBreaker: 6, abyssAdmiral: 0, saboteur: 0}, 703]",
	"partial": "[false, 30, 1, 0, 3, 6, 3, {guardian: 6, scout: 2}, {}, {scout: 2}, {guardian: 6}, 0, {guardian: 0, scout: 2, harpoonist: 0, domeBreaker: 0, abyssAdmiral: 0, saboteur: 0}, 693]",
	"tech": "[true, 30, 5, 5, 8, 5, 0, {guardian: 8, domeBreaker: 14}, {guardian: 3, domeBreaker: 13}, {guardian: 3, domeBreaker: 1}, {guardian: 2}, 5, {scout: 0, harpoonist: 0, guardian: 6, domeBreaker: 14, abyssAdmiral: 0, saboteur: 0}, 975]",
}


func test_kraken_waves_are_fought_as_dart_fights_them() -> void:
	_expect("empty", RaidSamples.volcano_player(3), 3, 1)
	_expect("level0", RaidSamples.volcano_player(0, {GUARDIAN: 2}), 0, 2)
	for seed_: int in [3, 4, 5]:
		var garrison: Dictionary[UnitType.Value, int] = {
			DOME_BREAKER: 8, GUARDIAN: 5, UnitType.Value.HARPOONIST: 4
		}
		_expect("garrison%d" % seed_, RaidSamples.volcano_player(2, garrison), 2, seed_)
	# A stock of the kernel holding two types only, the others come after.
	var kernel: Dictionary[UnitType.Value, Unit] = {
		GUARDIAN: Unit.new(GUARDIAN, 6), UnitType.Value.SCOUT: Unit.new(UnitType.Value.SCOUT, 2)
	}
	var base: Dictionary[UnitType.Value, Unit] = {}
	var per_level: Dictionary[int, Dictionary] = {1: base, KernelGarrison.STOCK_KEY: kernel}
	var partial := Player.new("p", "p", 0, 0, null, null, null, per_level)
	partial.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	_expect("partial", partial, 1, 6)
	var tech := RaidSamples.volcano_player(5, {DOME_BREAKER: 14, GUARDIAN: 8})
	tech.tech_branches[TechBranch.Value.MILITARY] = TechHelpers.researched_branch(
		TechBranch.Value.MILITARY, 4, [TechOption.Value.B, TechOption.Value.A]
	)
	_expect("tech", tech, 5, 7)


func _expect(name: String, player: Player, wave_level: int, seed_: int) -> void:
	var random := DartRandom.new(seed_)
	var wave := VolcanoWaveFactory.from_kernel_level(wave_level)
	var r := VolcanoBattle.fight(player, wave, 30, random)
	var stock := {}
	for type: UnitType.Value in KernelGarrison.stock_of(player):
		stock[type] = player.units_on_level(KernelGarrison.STOCK_KEY)[type].count
	var fields := PackedStringArray([
		r.victory, r.turn, r.kernel_level, r.kernel_level_after(), r.wave.unit_count,
		r.fight.turn_count, r.fight.final_monster_count, _units(r.defenders),
		_units(r.survivors_intact), _units(r.wounded), _units(r.dead),
		KernelGarrison.kernel_level_of(player), _units(stock), random.next_int(1000),
	].map(str))
	assert_eq("[%s]" % ", ".join(fields), DIGESTS[name], name)


## A map as Dart prints `{name: value, ...}`, in its order.
func _units(map: Dictionary) -> String:
	var pairs := PackedStringArray()
	for key: int in map:
		pairs.append("%s: %d" % [DartEnum.name_of(UnitType.Value, key), map[key]])
	return "{%s}" % ", ".join(pairs)
