class_name Greyscale
extends RefCounted
## Turns an icon grey: the greyscale of Flutter's `RasterSvg(greyscale: true)`
## for what is locked, not yet reachable or given up. A shader on the node, so
## the file stays one colour and the greying costs nothing to keep.

const SHADER := preload("res://presentation/ui/common/greyscale.gdshader")


## A material that draws in greys.
static func material() -> ShaderMaterial:
	var grey := ShaderMaterial.new()
	grey.shader = SHADER
	return grey


## Greys [param item] when [param on], draws it in its colours otherwise.
static func apply(item: CanvasItem, on := true) -> void:
	item.material = material() if on else null
