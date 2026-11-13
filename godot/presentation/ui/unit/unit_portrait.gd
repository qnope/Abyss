class_name UnitPortrait
extends RefCounted
## The picture of a unit (lib/presentation/widgets/unit/unit_icon.dart): its
## [Portrait], tinted with the unit's colour, or in the disabled grey with its
## render in greys (and faded) while it is locked or unavailable. Never an
## SVG: the units' art comes from the 3D models.


## The portrait of [param type], [param portrait_size] points across; grey
## when [param greyscale], and faded too when [param faded].
static func of(
	type: UnitType.Value, portrait_size := 40.0, greyscale := false, faded := false
) -> Portrait:
	var tint := AbyssColors.DISABLED if greyscale else UnitColors.of(type)
	var portrait := Portrait.new(
		UnitTexts.display_name(type), portrait_size, tint, PortraitFiles.unit(type), greyscale)
	if faded:
		portrait.modulate.a = AbyssColors.UNAVAILABLE_OPACITY
	return portrait
