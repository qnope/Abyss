class_name SafeArea
extends RefCounted
## The part of the screen a notch or a status bar covers, so that no screen
## puts a control under it.


## The height of the top edge the system covers, in the viewport's points,
## on the screen [param viewport] draws on.
static func top(viewport: Viewport) -> int:
	var points := viewport.get_visible_rect().size.y / maxf(viewport.get_window().size.y, 1.0)
	return top_in(DisplayServer.get_display_safe_area(), points)


## The height of the top edge outside [param safe], the safe area in pixels,
## when a pixel is [param points] points; 0 when the system gives no area.
static func top_in(safe: Rect2i, points: float) -> int:
	return roundi(safe.position.y * points) if safe.has_area() else 0
