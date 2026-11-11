class_name AbyssSwitchTheme
## The switch of lib/presentation/theme/abyss_input_theme.dart. Godot draws a
## CheckButton from icons, so the Switch variation draws its own: a rimmed
## track of Material 3's size with a thumb that is small and left when off,
## larger and right, in cyan, when on, as the four icons the CheckButton
## picks from. Off the track is surface dim rimmed in trench and the thumb
## dim; on, the track is cyan at 30 % rimmed in cyan. A disabled switch
## fades to Material's 38 %. The button draws nothing else.

const TYPE := &"Switch"
const TRACK := Vector2i(52, 32)
const OUTLINE := 2
const THUMB_OFF := 16
const THUMB_ON := 24
## Gap between the track's end and the thumb's edge, off and on.
const GAP_OFF := 8
const GAP_ON := 4
const DISABLED_OPACITY := 0.38


## Adds the Switch variation and its four icons to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(TYPE, &"CheckButton")
	for state: StringName in [&"normal", &"pressed", &"hover", &"hover_pressed", &"disabled", &"focus"]:
		theme.set_stylebox(state, TYPE, StyleBoxEmpty.new())
	theme.set_icon(&"checked", TYPE, icon(true, false))
	theme.set_icon(&"unchecked", TYPE, icon(false, false))
	theme.set_icon(&"checked_disabled", TYPE, icon(true, true))
	theme.set_icon(&"unchecked_disabled", TYPE, icon(false, true))


## The switch [param on] or off, faded when [param disabled].
static func icon(on: bool, disabled: bool) -> Texture2D:
	var fill := Color(AbyssColors.BIOLUM_CYAN, 0.3) if on else AbyssColors.SURFACE_DIM
	var edge := AbyssColors.BIOLUM_CYAN if on else AbyssColors.TRENCH
	var thumb := AbyssColors.BIOLUM_CYAN if on else AbyssColors.ON_SURFACE_DIM
	var radius := (THUMB_ON if on else THUMB_OFF) / 2.0
	var gap := GAP_ON if on else GAP_OFF
	var centre := Vector2(TRACK.x - gap - radius if on else gap + radius, TRACK.y / 2.0)
	var image := Image.create_empty(TRACK.x, TRACK.y, false, Image.FORMAT_RGBA8)
	var fade := DISABLED_OPACITY if disabled else 1.0
	var half := TRACK.y / 2.0
	for y in TRACK.y:
		for x in TRACK.x:
			var at := Vector2(x + 0.5, y + 0.5)
			var depth := _outside(at, half, TRACK.x - half) - half
			var rim := clampf(0.5 - depth, 0.0, 1.0) - clampf(0.5 - depth - OUTLINE, 0.0, 1.0)
			var inside := clampf(0.5 - depth - OUTLINE, 0.0, 1.0)
			var pixel := _weighted(edge, rim, fill, inside)
			var cover := clampf(radius + 0.5 - at.distance_to(centre), 0.0, 1.0)
			pixel = pixel.blend(Color(thumb, cover))
			image.set_pixel(x, y, Color(pixel, pixel.a * fade))
	return ImageTexture.create_from_image(image)


## How far [param at] is from the segment along the track's middle.
static func _outside(at: Vector2, from_x: float, to_x: float) -> float:
	return at.distance_to(Vector2(clampf(at.x, from_x, to_x), TRACK.y / 2.0))


## Two colours side by side, each at its own share of the pixel.
static func _weighted(a: Color, a_share: float, b: Color, b_share: float) -> Color:
	var alpha := a.a * a_share + b.a * b_share
	if alpha <= 0.0:
		return Color(a, 0.0)
	var rgb := (Vector3(a.r, a.g, a.b) * a.a * a_share + Vector3(b.r, b.g, b.b) * b.a * b_share) / alpha
	return Color(rgb.x, rgb.y, rgb.z, alpha)
