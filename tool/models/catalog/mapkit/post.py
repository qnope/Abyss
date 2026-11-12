"""What marks a post (la Faille, la Cheminée, the passage under them) as held:
a ring of light on the floor round it and a banner on a mast, both in the
node Tint so that the game gives them the colour of the holder (guardians,
the player, a faction), the mast and the rest of the post in the Body."""

from catalog import mapkit
from catalog.mapkit import tints
from catalog.parts import place


def marks(model, atlas, radius, mast_at, mast=0.55, sides=16, z=0.0, banner=(0.34, 0.22)):
    """The ring of [radius] at the height [z], and the banner on a [mast]
    high standing at [mast_at] (x, y)."""
    x, y = mast_at
    place(mapkit.body(model), tints.pole(atlas, mast), (x, y, 0.0))
    piece = mapkit.tint(model)
    place(piece, tints.ring(atlas, radius, 0.06, 0.02, sides=sides), (0, 0, z))
    place(piece, tints.banner(atlas, *banner), (x + 0.01, y, mast - banner[1] - 0.04))
