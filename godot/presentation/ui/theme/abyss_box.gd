class_name AbyssBox
## The style boxes of the theme, as Flutter's BoxDecoration: a rounded
## fill with its padding, then a rim, a shadow, an overlay. Each function
## but [method tinted] changes the box it is given and returns it, so they
## chain: [code]AbyssBox.rimmed(AbyssBox.flat(fill, 12), edge, 1.5)[/code].

## Share of a Material shadow's colour that its darkest part shows: the
## spot shadow alpha Flutter draws an elevation with.
const ELEVATION_ALPHA := 0.25


## A box filled with [param fill], its corners rounded by [param radius],
## its content [param padding] in from its sides (x) and its top and
## bottom (y). A transparent fill draws nothing.
static func flat(fill: Color, radius: int, padding := Vector2i.ZERO) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.draw_center = fill.a > 0.0
	box.set_corner_radius_all(radius)
	box.set_content_margin(SIDE_LEFT, padding.x)
	box.set_content_margin(SIDE_RIGHT, padding.x)
	box.set_content_margin(SIDE_TOP, padding.y)
	box.set_content_margin(SIDE_BOTTOM, padding.y)
	return box


## [param box] with a [param color] border [param width] pixels wide,
## rounded to whole pixels as Godot draws them: 1.5 gives 2.
static func rimmed(box: StyleBoxFlat, color: Color, width := 1.0) -> StyleBoxFlat:
	box.border_color = color
	box.set_border_width_all(roundi(width))
	return box


## [param box] rounded by [param radius] at its top corners only, as a
## bottom sheet.
static func top_rounded(box: StyleBoxFlat, radius: int) -> StyleBoxFlat:
	box.set_corner_radius_all(0)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	return box


## [param box] glowing as Flutter's BoxShadow of [param color], blurred by
## [param blur]: Godot's shadow fades out over its size, used as the blur.
static func glowing(box: StyleBoxFlat, color: Color, blur: int) -> StyleBoxFlat:
	box.shadow_color = color
	box.shadow_size = blur
	return box


## [param box] raised as a Material [param elevation] whose shadow is
## [param color]: a glow as wide as the elevation, at the spot shadow's
## share of the colour.
static func lifted(box: StyleBoxFlat, color: Color, elevation: int) -> StyleBoxFlat:
	return glowing(box, Color(color, color.a * ELEVATION_ALPHA), elevation)


## A copy of [param box] under [param overlay], as Material lays its
## hover and press overlays on a button.
static func tinted(box: StyleBoxFlat, overlay: Color) -> StyleBoxFlat:
	var tint := box.duplicate() as StyleBoxFlat
	tint.bg_color = box.bg_color.blend(overlay)
	tint.draw_center = tint.bg_color.a > 0.0
	return tint


## A disc of [param color], [param diameter] pixels across, such as a
## slider's thumb, its edge smoothed over a pixel.
static func disc(color: Color, diameter: int) -> Texture2D:
	var image := Image.create_empty(diameter, diameter, false, Image.FORMAT_RGBA8)
	var radius := diameter / 2.0
	for y in diameter:
		for x in diameter:
			var reach := Vector2(x + 0.5, y + 0.5).distance_to(Vector2(radius, radius))
			image.set_pixel(x, y, Color(color, color.a * clampf(radius - reach, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)
