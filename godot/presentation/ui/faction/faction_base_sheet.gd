class_name FactionBaseSheet
extends MapSheet
## What the player knows of a faction base it has seen
## (lib/presentation/widgets/faction/faction_base_sheet.dart): who the faction
## is ([FactionIdentity]) and its headquarters level, which is public, then the
## last report a Scout brought back ([BaseIntelReport]) or that there is none.
## The attack button is off, with the reason above it, while the attack is
## refused; the spy button is off while no Scout can go.
##
## The sheet only tells what the player wants: both signals come after it
## closed, for its owner to send the Scout or to pick the army.

## The player wants to send a Scout to the base.
signal spy_requested
## The player wants to attack the base.
signal attack_requested

const BUTTON_GAP := 12

var faction: Faction
var identity: FactionIdentity
var headquarters_row: SheetInfoRow
var intel_report: BaseIntelReport
var no_intel_label: Label
var cancel_button: Button
var spy_button: Button
var attack_button: Button


## The sheet of the base of [param faction_], whose headquarters stand at
## [param headquarters_level]. [param refusal] is the [ActionFailure] that
## forbids the attack now, [param spy_refusal] the one that forbids a Scout,
## null when allowed; [param intel] is the last report (null for none), read on
## [param turn].
func _init(
	faction_: Faction, headquarters_level: int, refusal: Variant, intel: BaseIntel, turn: int, spy_refusal: Variant
) -> void:
	faction = faction_
	super(null, Callable())
	identity = FactionIdentity.new(faction)
	column.add_child(identity)
	headquarters_row = SheetInfoRow.new(Texts.t.bind(&"factionBaseHeadquarters"),
		func() -> String: return str(headquarters_level))
	column.add_child(headquarters_row)
	if intel != null:
		intel_report = BaseIntelReport.new(intel, turn)
		column.add_child(intel_report)
	else:
		no_intel_label = label(Texts.t.bind(&"factionIntelNone"), &"BodySmall")
		no_intel_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
		column.add_child(no_intel_label)
	column.add_child(failure_label)
	if refusal != null:
		var reason: ActionFailure.Value = refusal
		tell(reason)
	column.add_child(HSeparator.new())
	cancel_button = button(Texts.t.bind(&"commonCancel"))
	cancel_button.theme_type_variation = &"TextButton"
	cancel_button.pressed.connect(close)
	spy_button = button(Texts.t.bind(&"factionSpy"))
	spy_button.theme_type_variation = &"OutlinedButton"
	spy_button.disabled = spy_refusal != null
	spy_button.pressed.connect(_then.bind(spy_requested))
	attack_button = button(Texts.t.bind(&"factionBaseAttack"))
	attack_button.disabled = refusal != null
	attack_button.pressed.connect(_then.bind(attack_requested))
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", BUTTON_GAP)
	for made: Button in [cancel_button, spy_button, attack_button]:
		buttons.add_child(made)
	column.add_child(buttons)


## Closes the sheet, then tells [param asked].
func _then(asked: Signal) -> void:
	close()
	asked.emit()
