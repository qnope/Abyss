class_name LevelSelector
extends RefreshingPanel
## The row of level chips for switching between the depths of the map
## (lib/presentation/widgets/map/level_selector.dart): "Niv. 1 : Surface",
## "Niv. 2 : Profondeurs"... The level on show is filled, the others dim,
## and a level not unlocked is disabled with a padlock. It owns no state but
## what it is given by [method show_state]; a touch on an unlocked level tells
## it with [signal level_selected]. The row scrolls sideways where it does not fit.

## The player touched the chip of [param level], unlocked.
signal level_selected(level: int)

## Room between the chips.
const GAP := 4
const HALO_RADIUS := 8
## The padlock of a level not unlocked.
const LOCK_SIZE := 16

var current := 1
var unlocked: Array[int] = [1]
## The chip of each level.
var chips: Dictionary[int, Button] = {}
var _halos: Dictionary[int, GuidedHalo] = {}
var _row := HBoxContainer.new()


## The chip of the level the guide points at is surrounded by its halo, unless
## that level is on show.
func _init(guide: GuideScope = null) -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override(&"separation", GAP)
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(_row)
	add_child(scroll)
	for level in MapLevelTexts.LEVELS:
		var chip := Button.new()
		chip.add_theme_constant_override(&"icon_max_width", LOCK_SIZE)
		chip.pressed.connect(_touched.bind(level))
		chips[level] = chip
		_halos[level] = GuidedHalo.new(chip, guide, _opens.bind(level), HALO_RADIUS)
		_row.add_child(_halos[level])
	refresh()


## Shows [param current_] lit, and the levels of [param unlocked_] open.
func show_state(current_: int, unlocked_: Array[int]) -> void:
	current = current_
	unlocked = unlocked_
	for halo: GuidedHalo in _halos.values():
		halo.follow()
	refresh()


func refresh() -> void:
	for level: int in chips:
		var chip := chips[level]
		chip.text = Texts.t(&"mapLevelChip", {"level": level, "name": MapLevelTexts.name_of(level)})
		chip.theme_type_variation = AbyssChipTheme.ACTIVE if level == current else AbyssChipTheme.CHIP
		chip.disabled = not unlocked.has(level)
		chip.icon = load(UiIcon.glyph_path(&"lock")) as Texture2D if chip.disabled else null


func _opens(target: GuideTarget, level: int) -> bool:
	return target.level == level and level != current


func _touched(level: int) -> void:
	level_selected.emit(level)
