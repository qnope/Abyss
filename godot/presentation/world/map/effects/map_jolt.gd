class_name MapJolt
extends RefCounted
## How far a blow shakes the map (lib/presentation/widgets/map/effects/
## map_jolt.dart): the camera moves side to side, in metres, dying out.


## How far a blow that landed [param since] seconds ago shakes the view, side
## to side, up to [param amplitude] metres, dying out over [param length]
## seconds; nothing before the blow (a negative time, [constant FightPace.NONE])
## or once it is over.
static func offset(since: float, length: float, amplitude: float) -> float:
	if since < 0.0 or since >= length:
		return 0.0
	var p := since / length
	return sin(p * 6.0 * PI) * amplitude * (1.0 - p)
