extends UnitTestCase
## The picker moves units for real when its owner wires its picks to an
## action (game_screen_troops_actions.dart: garrison the kernel).

var _acted := 0
var _player: Player
var _actions: GameActions


func before_each() -> void:
	super()
	_player = RaidSamples.volcano_player(1, {}, {Type.HARPOONIST: 10})
	_actions = GameActions.new(MoveSamples.volcano_game(_player))
	_actions.acted.connect(func(_result: Variant) -> void: _acted += 1)


func after_each() -> void:
	_actions = null


func _garrison_dialog() -> UnitPickerDialog:
	var available := KernelGarrison.stock_at(_player, KernelGarrison.VOLCANO_LEVEL)
	var dialog := UnitPickerDialog.new("Garnison", available, "Garnir")
	modals().open(dialog)
	dialog.confirmed.connect(func(picks: Dictionary[UnitType.Value, int]) -> void:
		_actions.execute(GarrisonKernelAction.new(picks)))
	return dialog


func test_the_picks_move_from_the_volcano_to_the_kernel() -> void:
	var dialog := _garrison_dialog()
	dialog.rows[Type.HARPOONIST].set_value(4)
	press(dialog.confirm_button)
	assert_eq(_acted, 1)
	assert_eq(KernelGarrison.stock_at(_player, KernelGarrison.VOLCANO_LEVEL)[Type.HARPOONIST].count, 6)
	assert_eq(KernelGarrison.stock_of(_player)[Type.HARPOONIST].count, 4)


func test_the_army_places_show_them_in_the_kernel() -> void:
	var dialog := _garrison_dialog()
	dialog.rows[Type.HARPOONIST].set_value(4)
	press(dialog.confirm_button)
	var places := ArmyPlaces.of(_player)
	assert_eq(places.count_of(Type.HARPOONIST, KernelGarrison.STOCK_KEY), 4)
	assert_eq(places.count_of(Type.HARPOONIST, KernelGarrison.VOLCANO_LEVEL), 6)


func test_cancelling_moves_nothing() -> void:
	var dialog := _garrison_dialog()
	dialog.rows[Type.HARPOONIST].set_value(4)
	press("Annuler")
	assert_eq(_acted, 0)
	assert_eq(KernelGarrison.stock_of(_player)[Type.HARPOONIST].count, 0)
