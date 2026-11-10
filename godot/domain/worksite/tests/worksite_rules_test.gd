extends VectorTestCase
## test/domain/worksite/worksite_rules_test.dart: how many upgrades and
## research nodes a turn allows, and the worksites section of buildings.json.


func test_worksite_rules_one_site_then_one_more_at_hq_5_and_at_hq_10() -> void:
	assert_eq(WorksiteRules.build_sites(0), 1)
	assert_eq(WorksiteRules.build_sites(4), 1)
	assert_eq(WorksiteRules.build_sites(5), 2)
	assert_eq(WorksiteRules.build_sites(9), 2)
	assert_eq(WorksiteRules.build_sites(10), 3)


func test_worksite_rules_names_the_hq_level_that_opens_the_next_site() -> void:
	assert_eq(WorksiteRules.next_site_at_hq(1), 5)
	assert_eq(WorksiteRules.next_site_at_hq(5), 10)
	assert_null(WorksiteRules.next_site_at_hq(10))


func test_worksite_counts_the_free_sites_left_this_turn() -> void:
	var site := Worksite.new(1)
	assert_eq(site.free_build_sites(1), 0)
	assert_eq(site.free_build_sites(5), 1)


func test_worksite_allows_one_research_per_turn() -> void:
	var site := Worksite.new()
	assert_true(site.can_research())
	site.research = 1
	assert_false(site.can_research())


func test_worksite_clear_frees_every_site_and_the_laboratory() -> void:
	var site := Worksite.new(2, 1)
	site.clear()
	assert_eq(site.upgrades, 0)
	assert_eq(site.research, 0)


func test_worksites_vectors() -> void:
	var cases := VectorFile.new("buildings").cases("worksites")
	assert_eq(cases.size(), 11)
	for case: Dictionary in cases:
		var hq: int = case["hq"]
		var out := {
			"buildSites": WorksiteRules.build_sites(hq),
			"nextSiteAtHq": WorksiteRules.next_site_at_hq(hq),
		}
		assert_same(out, case["out"], str(case))
