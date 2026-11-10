class_name TutorialOffer
extends RefCounted
## lib/domain/objective/tutorial_offer.dart: when the new game screen offers
## the tutorial checked.

## The turn from which a game shows the player knows the ropes.
const EXPERIENCED_TURN := 20


## Whether the tutorial starts checked: as long as none of the `saved` games
## reached EXPERIENCED_TURN.
static func checked_by_default(saved: Array[Game]) -> bool:
	for game: Game in saved:
		if game.turn >= EXPERIENCED_TURN:
			return false
	return true
