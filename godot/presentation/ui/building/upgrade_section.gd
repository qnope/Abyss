class_name UpgradeSection
extends VBoxContainer
## What it takes to raise (or build) a building, and the button that does it
## (lib/presentation/widgets/building/upgrade_section.dart): "Niveau 2 → 3",
## the cost in resources, the noise it makes, the buildings it asks for, the
## base or the kernel it asks to have captured and the worksite it needs, each
## in red until met. The button is lit when the building can rise right now,
## and tells [signal upgrade_pressed]. At its top level only a line says so.
## It is built from a [BuildingView]; the sheet builds it again on each change.

## The player pressed the button.
signal upgrade_pressed

const GAP := 8
const ROW_GAP := 4
const BUTTON_GAP := 12

var view: BuildingView
var button: Button


func _init(view_: BuildingView) -> void:
	view = view_
	add_theme_constant_override(&"separation", ROW_GAP)
	if view.readiness.check.is_max_level:
		var line := Label.new()
		line.text = Texts.t(&"baseMaxLevel")
		line.add_theme_color_override(&"font_color", AbyssColors.DISABLED)
		add_child(line)
		return
	var level := view.building.level
	var title := Label.new()
	title.theme_type_variation = &"TitleSmall"
	title.text = Texts.t(&"baseUpgradeLevels", {"from": level, "to": level + 1})
	add_child(title)
	_add_costs(level)
	_add_locks()
	button = Button.new()
	button.text = Texts.t(&"baseBuild" if level == 0 else &"baseUpgrade")
	button.disabled = not view.readiness.is_ready()
	button.pressed.connect(upgrade_pressed.emit)
	var gap := Control.new()
	gap.custom_minimum_size.y = BUTTON_GAP - ROW_GAP
	add_child(gap)
	add_child(button)


func _add_costs(level: int) -> void:
	var costs := view.calculator.upgrade_cost(view.type, level)
	for type: ResourceType.Value in costs:
		var available := view.resources[type].amount if view.resources.has(type) else 0
		add_child(RequirementRow.new(ResourceIcon.new(type, RequirementRow.ICON_SIZE),
			ResourceTexts.display_name(type), "%d/%d" % [available, costs[type]], available >= costs[type]))
	add_child(NoiseCostRow.new(NoiseRules.for_upgrade(view.type, level + 1)))
	var needs := view.calculator.prerequisites(view.type, level + 1)
	for type: BuildingType.Value in needs:
		var met := view.level_of(type) >= needs[type]
		add_child(RequirementRow.locked(BuildingTexts.display_name(type),
			Texts.t(&"baseLevelShort", {"level": needs[type]}), met))


func _add_locks() -> void:
	var check := view.readiness.check
	if check.missing_captured_base != null:
		var base: TransitionBaseType.Value = check.missing_captured_base
		add_child(RequirementRow.locked(Texts.t(&"baseCapturedBaseRequired",
			{"base": TransitionBaseTexts.display_name(base)}), "", false))
	if check.missing_captured_kernel:
		add_child(RequirementRow.locked(Texts.t(&"baseKernelRequired"), "", false))
	if not view.readiness.site_free:
		add_child(RequirementRow.locked(Texts.t(&"baseWorksitesBusy"), "", false))
