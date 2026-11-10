extends TestCase
## Not in the Dart file: the advice the Dart rules give, read by a scratch
## script run with `dart run` on lib/domain, on raidPlayer bases with and
## without a Citadel, defenders and research, and the advice that forgets
## the defenders (harpoonistsAlone, which no Dart test reads).

const SWARM := MonsterFamily.Value.SWARM

var _swarm := MonsterLair.new(MonsterDifficulty.Value.EASY, 22, SWARM, MonsterFamily.Value.ARMOURED, 6)
var _mixed := MonsterLair.new(
	MonsterDifficulty.Value.MEDIUM, 11, MonsterFamily.Value.HUNTER, MonsterFamily.Value.COLOSSUS, 2
)


func test_advises_as_dart_does() -> void:
	var tech := RaidSamples.raid_player({UnitType.Value.DOME_BREAKER: 3}, 1)
	tech.tech_branches[TechBranch.Value.MILITARY] = TechHelpers.researched_branch(
		TechBranch.Value.MILITARY, 4, [TechOption.Value.B, TechOption.Value.A]
	)
	var defended := RaidSamples.raid_player({UnitType.Value.GUARDIAN: 6, UnitType.Value.SCOUT: 2}, 2)
	var got := [
		RaidDefenceAdvisor.harpoonists_for(RaidSamples.raid_player(), _swarm),
		RaidDefenceAdvisor.harpoonists_for(RaidSamples.raid_player({}, 5), _swarm),
		RaidDefenceAdvisor.harpoonists_for(defended, _mixed),
		RaidDefenceAdvisor.harpoonists_for(tech, _mixed),
		RaidDefenceAdvisor.harpoonists_alone(RaidSamples.raid_player(), _swarm),
		RaidDefenceAdvisor.harpoonists_alone(tech, _mixed),
	]
	assert_eq(got, [11, 4, 15, 18, 11, 24])


func test_forgets_its_last_answer_between_test_files() -> void:
	var player := RaidSamples.raid_player()
	RaidDefenceAdvisor.harpoonists_for(player, _swarm)
	RaidDefenceAdvisor.debug_reset()
	assert_eq(RaidDefenceAdvisor.harpoonists_for(player, _swarm), 11)
