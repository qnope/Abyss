extends TestCase
## test/domain/faction/faction_post_war_test.dart: a faction takes the posts
## of the others on its war slot.

const Kind := TransitionBaseType.Value


static func _scene(kind: Kind) -> PostWar:
	var war := PostWar.new(kind)
	while not FactionWar.is_due(war.game.turn, war.game.factions()[0].personality):
		war.game.turn += 1
	return war


static func _play(war: PostWar) -> void:
	FactionWar.play(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)),
		war.game.factions()[0].personality,
	)


func test_a_faction_takes_a_weakly_held_post_it_has_seen() -> void:
	for kind: Kind in Kind.values():
		var war := _scene(kind)
		war.arm(war.attacker())
		war.put(war.owner(), war.below(), PostWar.GARRISON)

		_play(war)

		var name := DartEnum.name_of(Kind, kind)
		assert_eq(war.post.captured_by, war.attacker().id, name)
		assert_eq(war.owner().buildings[war.passage()].level, 0, name)
		assert_eq(War.assaults(war.owner()).size(), 1, name)


func test_it_leaves_a_post_whose_defence_it_would_not_beat() -> void:
	var war := _scene(Kind.FAILLE)
	war.arm(war.attacker(), {UnitType.Value.HARPOONIST: 6})
	war.put(war.owner(), 2, PostWar.WALL)

	_play(war)

	assert_eq(war.post.captured_by, war.owner().id)
	assert_eq(War.assaults(war.attacker()).size(), 0)


func test_it_ignores_a_post_its_fog_has_not_shown() -> void:
	var war := _scene(Kind.FAILLE)
	war.arm(war.attacker())
	war.attacker().revealed_cells_per_level[1] = [] as Array[GridPosition]

	_play(war)

	assert_eq(war.post.captured_by, war.owner().id)


func test_it_does_not_attack_its_own_post() -> void:
	var war := _scene(Kind.FAILLE)
	war.arm(war.attacker())
	war.post.captured_by = war.attacker().id

	_play(war)

	assert_eq(War.assaults(war.attacker()).size(), 0)


func test_a_post_of_the_human_falls_at_once_without_announcement() -> void:
	var war := _scene(Kind.FAILLE)
	war.arm(war.attacker())
	war.post.captured_by = war.human().id
	war.human().buildings[war.passage()] = war.owner().buildings[war.passage()]
	var human := war.human()

	_play(war)

	assert_eq(war.post.captured_by, war.attacker().id)
	assert_eq(human.raid_state.attacks.size(), 0)
	var entries := War.assaults(human)
	assert_eq(entries.size(), 1)
	assert_true(entries[0].defending)
	assert_eq(entries[0].post_name, war.post.name)


## Not in the Dart file: a fallen owner keeps its post, and a cell that only
## keeps the post under another content is no target.
func test_it_leaves_the_post_of_a_fallen_owner_or_one_under_another_content() -> void:
	var war := _scene(Kind.FAILLE)
	war.arm(war.attacker())
	war.put(war.owner(), war.below(), PostWar.GARRISON)
	war.owner().saved_fallen = true
	_play(war)
	assert_eq(war.post.captured_by, war.owner().id)
	war.owner().saved_fallen = false
	var map: GameMap = war.game.levels[war.level]
	var cell := map.cell_at(war.at.x, war.at.y)
	map.set_cell(war.at.x, war.at.y, cell.copy_with({"content": CellContentType.Value.EMPTY}))
	_play(war)
	assert_eq(war.post.captured_by, war.owner().id)
