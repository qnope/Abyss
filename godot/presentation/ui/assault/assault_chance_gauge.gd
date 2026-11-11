class_name AssaultChanceGauge
extends RefreshingPanel
## The chance of an assault (lib/presentation/widgets/fight/
## assault_chance_gauge.dart): its rating and the rehearsals won
## ("Élevées · 19 sur 20"), over a bar filled to the share won and coloured by
## the rating.

const GAP := 6
const BAR_HEIGHT := 8.0

var chance := AssaultChance.none()
var title_label := Label.new()
var rating_label := Label.new()
var bar := ProgressBar.new()


func _init() -> void:
	super()
	title_label.theme_type_variation = &"BodyMedium"
	title_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rating_label.theme_type_variation = &"LabelLarge"
	bar.max_value = 1.0
	bar.show_percentage = false
	bar.custom_minimum_size.y = BAR_HEIGHT
	var texts_row := HBoxContainer.new()
	texts_row.add_child(title_label)
	texts_row.add_child(rating_label)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(texts_row)
	column.add_child(bar)
	add_child(column)
	show_chance(chance)


## The theme variation of the bar for [param rating].
static func variation_of(rating: AssaultRating.Value) -> StringName:
	match rating:
		AssaultRating.Value.HIGH:
			return AbyssInputTheme.CHANCE_HIGH
		AssaultRating.Value.RISKY:
			return AbyssInputTheme.CHANCE_RISKY
	return AbyssInputTheme.CHANCE_LOW


## The colour that tells [param rating] at a glance.
static func color_of(rating: AssaultRating.Value) -> Color:
	match rating:
		AssaultRating.Value.HIGH:
			return AbyssColors.SUCCESS
		AssaultRating.Value.RISKY:
			return AbyssColors.WARNING
	return AbyssColors.ERROR


## Shows [param new_chance].
func show_chance(new_chance: AssaultChance) -> void:
	chance = new_chance
	var rating := chance.rating()
	bar.theme_type_variation = variation_of(rating)
	bar.value = chance.rate()
	rating_label.add_theme_color_override(&"font_color", color_of(rating))
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"assaultPlanChances")
	# An army without admiral is not rehearsed: out of as many as the rest.
	var rehearsals := chance.rehearsals if chance.rehearsals != 0 else AssaultPlan.rehearsals()
	var rating: String = DartEnum.name_of(AssaultRating.Value, chance.rating())
	rating_label.text = Texts.t(&"assaultPlanRating", {"rating": rating, "wins": chance.wins, "rehearsals": rehearsals})
