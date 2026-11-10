extends TestCase
## test/domain/tech/tech_perk_test.dart: the effect each option of a choice
## node grants.

const A := TechOption.Value.A
const B := TechOption.Value.B
const NAMES: Array[String] = [
	"coralBlades", "nacreShell", "livingRampart", "deepAssault",
	"intensiveFarming", "deepDrilling", "sealedChests", "thriftyWorksites",
	"deepSonar", "silentSwim", "wreckRaiders", "sentinels",
]


func test_tech_perk_of_military_options() -> void:
	var m := TechBranch.Value.MILITARY
	assert_eq(TechPerk.of(m, 2, A), TechPerk.Value.CORAL_BLADES)
	assert_eq(TechPerk.of(m, 2, B), TechPerk.Value.NACRE_SHELL)
	assert_eq(TechPerk.of(m, 4, A), TechPerk.Value.LIVING_RAMPART)
	assert_eq(TechPerk.of(m, 4, B), TechPerk.Value.DEEP_ASSAULT)


func test_tech_perk_of_resources_options() -> void:
	var r := TechBranch.Value.RESOURCES
	assert_eq(TechPerk.of(r, 2, A), TechPerk.Value.INTENSIVE_FARMING)
	assert_eq(TechPerk.of(r, 2, B), TechPerk.Value.DEEP_DRILLING)
	assert_eq(TechPerk.of(r, 4, A), TechPerk.Value.SEALED_CHESTS)
	assert_eq(TechPerk.of(r, 4, B), TechPerk.Value.THRIFTY_WORKSITES)


func test_tech_perk_of_explorer_options() -> void:
	var e := TechBranch.Value.EXPLORER
	assert_eq(TechPerk.of(e, 2, A), TechPerk.Value.DEEP_SONAR)
	assert_eq(TechPerk.of(e, 2, B), TechPerk.Value.SILENT_SWIM)
	assert_eq(TechPerk.of(e, 4, A), TechPerk.Value.WRECK_RAIDERS)
	assert_eq(TechPerk.of(e, 4, B), TechPerk.Value.SENTINELS)


func test_tech_perk_of_shared_tiers_grant_no_perk() -> void:
	for branch: TechBranch.Value in TechBranch.Value.values():
		for level: int in [1, 3, 5]:
			assert_null(TechPerk.of(branch, level, A))


func test_tech_perk_of_every_perk_belongs_to_exactly_one_node_option() -> void:
	var all := []
	var distinct := {}
	for branch: TechBranch.Value in TechBranch.Value.values():
		for level: int in [2, 4]:
			for option: TechOption.Value in TechOption.Value.values():
				all.append(TechPerk.of(branch, level, option))
				distinct[TechPerk.of(branch, level, option)] = true
	assert_eq(distinct.keys(), TechPerk.Value.values())
	assert_eq(all.size(), TechPerk.Value.size())


## Not in the Dart file: the names and the order the vectors write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(TechPerk.Value), PackedStringArray(NAMES))
