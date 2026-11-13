class_name RenderScale
extends RefCounted
## The share of the screen's pixels the 3D is drawn at. The game is fill-rate
## bound on a phone: the lighting, the shadows, the map's fog and the glow are
## paid per pixel, and a canvas that follows the screen's density gives an
## iPhone (density 3) 2.6 million of them where density 2 would give 1.15. So
## the 3D is drawn at twice the points at most and stretched to the screen
## (bilinear on the Compatibility renderer; at 2/3 a software render of the
## map takes about 30 % less time a frame). The 2D interface is not scaled: it
## keeps every pixel. Nothing changes on a screen of density 1 or 2.

## The densest the 3D is drawn at, in pixels per point: a denser screen draws
## it as a screen of this density would.
const MAX_DENSITY := 2.0


## The 3D render scale on a screen of [param density] pixels per point: 1 up
## to [constant MAX_DENSITY], MAX_DENSITY / density beyond. Never above 1: a
## density the system does not know (0) draws every pixel.
static func of(density: float) -> float:
	return MAX_DENSITY / maxf(density, MAX_DENSITY)


## Caps the 3D of [param viewport] for a screen of [param density], the
## screen's own unless told (the device pixel ratio on the web).
static func apply(viewport: Viewport, density := DisplayServer.screen_get_scale()) -> void:
	viewport.scaling_3d_scale = of(density)
