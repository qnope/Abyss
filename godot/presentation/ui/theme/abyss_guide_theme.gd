class_name AbyssGuideTheme
## The halo the tutorial's guide puts around what it asks the player to
## touch (lib/presentation/widgets/guide/guide_halo_painter.dart): a cyan
## rim and a glow that pulse together. [method halo] gives the style box at
## a point of the pulse, from 0 (dimmest) to 1 (brightest); the GuideHalo
## component animates it.
##
## Flutter paints a blurred 5 to 10 px stroke and a crisp 2 px one on top; a
## StyleBoxFlat draws a rim and a shadow as wide as its blur, so the rim is
## the crisp stroke and the shadow the blur: 6 to 12 px wide.

const CYAN := AbyssColors.BIOLUM_CYAN
## The type variation of the guide's speech bubble (guide_bubble.dart).
const BUBBLE := &"GuideBubble"
## Width of the crisp rim, also the gap between the halo and what it surrounds.
const RIM_WIDTH := 2
const GLOW_MIN := 6
const GLOW_MAX := 12
## One beat of the pulse, in seconds: dimmest to brightest.
const BEAT := 0.9


## The halo at [param pulse], rounded by [param radius] (a very large one
## makes a circle), drawn [param inset] pixels inside the box it surrounds.
static func halo(pulse: float, radius: int, inset := 0) -> StyleBoxFlat:
	var box := AbyssBox.flat(Color.TRANSPARENT, radius)
	AbyssBox.rimmed(box, Color(CYAN, 0.55 + 0.45 * pulse), RIM_WIDTH)
	AbyssBox.glowing(box, Color(CYAN, 0.35 + 0.45 * pulse), roundi(lerpf(GLOW_MIN, GLOW_MAX, pulse)))
	box.set_content_margin_all(RIM_WIDTH)
	box.set_expand_margin_all(-inset)
	return box


## What stands where the halo is not shown, so that the content does not
## move when it appears: nothing, as wide as the rim.
static func idle() -> StyleBoxEmpty:
	var box := StyleBoxEmpty.new()
	box.set_content_margin_all(RIM_WIDTH)
	return box


## Adds the speech bubble to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(BUBBLE, &"PanelContainer")
	theme.set_stylebox(&"panel", BUBBLE, bubble())


## The bubble the guide speaks in: surface light, rimmed and glowing faintly
## in cyan, padded as guide_bubble.dart (8 around, 12 at the right).
static func bubble() -> StyleBoxFlat:
	var box := AbyssBox.flat(AbyssColors.SURFACE_LIGHT, 16, Vector2i(10, 8))
	return AbyssBox.glowing(AbyssBox.rimmed(box, Color(CYAN, 0.4)), Color(CYAN, 0.15), 12)
