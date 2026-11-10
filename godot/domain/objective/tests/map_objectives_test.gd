extends TestCase
## test/domain/objective/map_objectives_test.dart: the objectives read from
## the maps: a lair, a post or the kernel taken, a level reached.

const Id := ObjectiveId.Value
const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


func test_map_objectives_take_lair_un_repaire_vaincu_par_le_joueur() -> void:
	var game := ObjectiveSamples.objective_game()
	_place(game, 1, _lair())
	_expect(game, Id.TAKE_LAIR, 0)
	_place(game, 1, _lair("someone else"))
	_expect(game, Id.TAKE_LAIR, 0)
	_place(game, 2, _lair(game.human_player_id))
	_expect(game, Id.TAKE_LAIR, 1)


func test_map_objectives_take_faille_la_faille_capturee_par_le_joueur() -> void:
	var game := ObjectiveSamples.objective_game()
	_place(game, 1, _base(FAILLE))
	_expect(game, Id.TAKE_FAILLE, 0)
	_place(game, 1, _base(FAILLE, game.human_player_id))
	_expect(game, Id.TAKE_FAILLE, 1)


func test_map_objectives_take_cheminee_la_cheminee_capturee_pas_la_faille() -> void:
	var game := ObjectiveSamples.objective_game()
	_place(game, 1, _base(FAILLE, game.human_player_id))
	_expect(game, Id.TAKE_CHEMINEE, 0)
	_place(game, 2, _base(CHEMINEE, game.human_player_id))
	_expect(game, Id.TAKE_CHEMINEE, 1)


func test_map_objectives_take_kernel_le_noyau_volcanique_pris_par_le_joueur() -> void:
	var game := ObjectiveSamples.objective_game()
	_place(game, 3, _kernel())
	_expect(game, Id.TAKE_KERNEL, 0)
	_place(game, 3, _kernel(game.human_player_id))
	_expect(game, Id.TAKE_KERNEL, 1)


func test_map_objectives_descend_level_2_zone_d_arrivee_revelee_au_niveau_2() -> void:
	var game := ObjectiveSamples.objective_game()
	game.levels[2] = ObjectiveSamples.plain_map()
	_expect(game, Id.DESCEND_LEVEL_2, 0)
	game.human_player().add_revealed_cell(2, GridPosition.new(1, 1))
	_expect(game, Id.DESCEND_LEVEL_2, 1)


func test_map_objectives_descend_level_3_des_unites_du_joueur_au_niveau_3() -> void:
	var game := ObjectiveSamples.objective_game()
	game.levels[3] = ObjectiveSamples.plain_map()
	RaidSamples.set_units(game.human_player(), UnitType.Value.SCOUT, 0, 3)
	_expect(game, Id.DESCEND_LEVEL_3, 0)
	RaidSamples.set_units(game.human_player(), UnitType.Value.GUARDIAN, 2, 3)
	_expect(game, Id.DESCEND_LEVEL_3, 1)


func test_map_objectives_descend_level_3_rien_sans_carte_du_niveau_3() -> void:
	var game := ObjectiveSamples.objective_game()
	RaidSamples.set_units(game.human_player(), UnitType.Value.GUARDIAN, 2, 3)
	_expect(game, Id.DESCEND_LEVEL_3, 0)


## `place`: `cell` at (7, 7) of `level`, a plain map made for a new level.
func _place(game: Game, level: int, cell: MapCell) -> void:
	if not game.levels.has(level):
		game.levels[level] = ObjectiveSamples.plain_map()
	game.levels[level].set_cell(7, 7, cell)


func _lair(by: Variant = null) -> MapCell:
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 3)
	return MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR, lair, by)


func _base(type: TransitionBaseType.Value, by: Variant = null) -> MapCell:
	var base := TransitionBase.new(type, "X", by)
	return MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)


func _kernel(by: Variant = null) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, by)


func _expect(game: Game, id: Id, current: int) -> void:
	var expected := ObjectiveSamples.expected(current, 1)
	assert_eq(ObjectiveSamples.progress(game, id), expected, DartEnum.name_of(Id, id))
