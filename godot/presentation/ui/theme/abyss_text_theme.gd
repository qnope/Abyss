class_name AbyssTextTheme
## The text roles of lib/presentation/theme/abyss_text_theme.dart, as
## Label variations named after Flutter's TextTheme roles: a Label picks
## one with theme_type_variation, such as &"TitleLarge". A plain Label
## reads as BodyMedium, as Flutter's default text does.

const LABEL := &"Label"
## The Body roles in dimmed italics (lib/.../lore_text.dart), by role.
const LORE: Dictionary[StringName, StringName] = {
	&"BodyLarge": &"LoreLarge", &"BodyMedium": &"Lore", &"BodySmall": &"LoreSmall",
}
const LEAN := 0.2


## Flutter's TextTheme roles, and the two named styles of the text theme.
static func roles() -> Dictionary[StringName, AbyssTextStyle]:
	const D := AbyssFonts.Weight.DEFAULT
	const M := AbyssFonts.Weight.MEDIUM
	const S := AbyssFonts.Weight.SEMI_BOLD
	const B := AbyssFonts.Weight.BOLD
	const CYAN := AbyssColors.BIOLUM_CYAN
	const TEXT := AbyssColors.ON_SURFACE
	const DIM := AbyssColors.ON_SURFACE_DIM
	return {
		&"DisplayLarge": AbyssTextStyle.new(40, B, CYAN, 1.5),
		&"DisplayMedium": AbyssTextStyle.new(32, S, CYAN),
		&"DisplaySmall": AbyssTextStyle.new(24, S, AbyssColors.BIOLUM_TEAL),
		&"HeadlineLarge": AbyssTextStyle.new(22, B, TEXT),
		&"HeadlineMedium": AbyssTextStyle.new(20, S, TEXT),
		&"HeadlineSmall": AbyssTextStyle.new(18, M, TEXT),
		&"TitleLarge": AbyssTextStyle.new(18, S, CYAN),
		&"TitleMedium": AbyssTextStyle.new(16, M, TEXT),
		&"TitleSmall": AbyssTextStyle.new(14, M, DIM),
		&"BodyLarge": AbyssTextStyle.new(16, D, TEXT),
		&"BodyMedium": AbyssTextStyle.new(14, D, TEXT),
		&"BodySmall": AbyssTextStyle.new(12, D, DIM),
		&"LabelLarge": AbyssTextStyle.new(14, S, AbyssColors.ABYSS_BLACK, 1.2),
		&"LabelMedium": AbyssTextStyle.new(12, M, TEXT),
		&"LabelSmall": AbyssTextStyle.new(10, M, DIM, 1.0),
		# Small spaced capitals heading a section of a list, e.g. « EN COURS ».
		&"SectionLabel": AbyssTextStyle.new(13, B, DIM, 3),
		# Capitals inside a small pill, such as a difficulty or an outcome.
		&"PillLabel": AbyssTextStyle.new(11, B, TEXT, 1),
	}


## The role every button label takes, as Flutter's buttons do.
static func button_label() -> AbyssTextStyle:
	return roles()[&"LabelLarge"]


## Adds every role to [param theme] as a Label variation, [param theme]'s
## default size and the plain Label's colour.
static func apply(theme: Theme) -> void:
	var body := roles()[&"BodyMedium"]
	theme.default_font_size = body.size
	theme.set_font_size(&"font_size", LABEL, body.size)
	theme.set_color(&"font_color", LABEL, body.color)
	var all := roles()
	for role in all:
		add_label(theme, role, all[role])
	for role in LORE:
		var base: AbyssTextStyle = all[role]
		var lore := AbyssTextStyle.new(base.size, base.weight, AbyssColors.ON_SURFACE_DIM)
		lore.slant = LEAN
		add_label(theme, LORE[role], lore)


## Adds [param style] to [param theme] as the Label variation [param name].
static func add_label(theme: Theme, name: StringName, style: AbyssTextStyle) -> void:
	theme.set_type_variation(name, LABEL)
	style.apply_to(theme, name)
