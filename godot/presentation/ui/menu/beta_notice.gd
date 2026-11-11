class_name BetaNotice
extends RefreshingPanel
## One discreet line warning that the game is a beta whose saves may be wiped
## (lib/presentation/widgets/menu/beta_notice.dart): a warning sign, the
## version in warning colour, and the warning, centred and wrapping.

const ICON_SIZE := 15.0

var version_label := Label.new()
var warning_label := Label.new()


func _init() -> void:
	super()
	var flow := HFlowContainer.new()
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.add_theme_constant_override(&"h_separation", 4)
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sign_icon := UiIcon.glyph(&"warning", ICON_SIZE, AbyssColors.WARNING)
	version_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	for line: Label in [version_label, warning_label]:
		line.theme_type_variation = &"Footnote"
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flow.add_child(sign_icon)
	flow.add_child(version_label)
	flow.add_child(warning_label)
	add_child(flow)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	refresh()


func refresh() -> void:
	version_label.text = Texts.t(&"menuBetaVersion", {"version": AppVersion.current()})
	warning_label.text = "· " + Texts.t(&"menuBetaWarning")
