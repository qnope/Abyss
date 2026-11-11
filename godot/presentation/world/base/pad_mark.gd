class_name PadMark
extends Sprite3D
## A sign floating over a pad, always facing the camera and drawn over the
## buildings so that it reads from any side: an arrow over a building that can
## rise, a plus over a plot that can be built on, a padlock over a plot held
## back, a warning over a building that works badly (the chevron, the lock
## and the triangle of the Flutter base). Drawn from the interface's glyphs
## (assets/icons/ui/), tinted.

enum Kind { UPGRADE, BUILD, LOCKED, DEGRADED }

## The width of the sign in metres.
const WIDTH := 0.8
const GLYPH_PIXELS := 192.0
const ICONS: Dictionary[Kind, String] = {
	Kind.UPGRADE: "res://assets/icons/ui/arrow_upward.svg",
	Kind.BUILD: "res://assets/icons/ui/add.svg",
	Kind.LOCKED: "res://assets/icons/ui/lock.svg",
	Kind.DEGRADED: "res://assets/icons/ui/warning.svg",
}

var kind: Kind


func _init(kind_: Kind) -> void:
	kind = kind_
	name = &"Mark"
	texture = load(ICONS[kind]) as Texture2D
	pixel_size = WIDTH / GLYPH_PIXELS
	modulate = tint_of(kind)
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 1
	shaded = false
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


## The colour of the sign of [param kind].
static func tint_of(kind_: Kind) -> Color:
	match kind_:
		Kind.UPGRADE:
			return WorldPalette.UPGRADE
		Kind.BUILD:
			return WorldPalette.BUILD
		Kind.LOCKED:
			return WorldPalette.LOCKED
	return WorldPalette.WARNING
