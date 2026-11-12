"""The passage: what appears under a post once it is taken, an opened way down.
A low octagonal collar of blue-grey steel round a
black shaft with a warm light far down it, its round lid thrown open on a
hinge behind it, hazard stripes on the rim, and a mast with a banner by it.
The flattest content of the map (the collar is a tenth of a cell high); the
banner and the ring of lights on its rim, in the node Tint, wear the colour of
whoever holds the post.

Tintable: Tint = the ring of lights and the banner (neutral white by default,
the guardians' grey in the game). Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.mapkit import tints
from catalog.parts import extrude, place
from catalog.paints import machined
from catalog.textures import map as tiles
from workshop import shapes

NAME = "map_passage"
SEED = 7501
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("white", "amber", "dark", "plates", "hazard")
BUDGET = mapkit.budget(1_800)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY, mapkit.TINT]
OUTER, INNER, HEIGHT = 0.42, 0.28, 0.1


def build(model):
    atlas, into = model.atlas, mapkit.body(model)
    collar = extrude.collar(OUTER, OUTER - INNER, HEIGHT, sides=8, smooth=False)
    into.add(collar, "hull", machined(colors.HULL, 1, soot=0.2, height=0.1), atlas.tiled("plates", 0.5)(collar))
    for k in range(8):  # a hazard stripe on every other face of the rim
        if k % 2:
            continue
        a = math.pi / 8 + k * math.pi / 4
        stripe = shapes.box((0.16, 0.04, 0.012)).transform(
            ((OUTER - 0.07) * math.cos(a), (OUTER - 0.07) * math.sin(a), HEIGHT), (0, 0, a + math.pi / 2))
        into.add(stripe, "hull", colors.WHITE, atlas.fit("hazard")(stripe))
    shaft = shapes.cylinder(INNER, 0.02, sides=8, smooth=False).transform((0, 0, 0.012))
    into.add(shaft, "hull", (0.01, 0.01, 0.014), atlas.solid("plain")(shaft))
    light = shapes.cylinder(INNER * 0.55, 0.02, sides=8, smooth=False).transform((0, 0.04, 0.03))
    into.add(light, "lamp", colors.LAMP, atlas.solid("amber")(light))
    _lid(into, atlas)
    place(into, tints.pole(atlas, 0.55), (-OUTER - 0.02, -0.12, 0.0))
    _tint(model, atlas)


def _lid(into, atlas):
    """The round lid, hinged on the collar's back edge and flung open."""
    lid = shapes.cylinder(INNER + 0.05, 0.03, sides=8, bevel=0.008, smooth=False)
    lid.transform((0, -(INNER + 0.05), 0))
    extrude.tilted(lid, (0.0, 0.0), -math.radians(105)).transform((0, OUTER - 0.02, HEIGHT))
    into.add(lid, "hull", machined(colors.HULL_DARK, 2, soot=0.1), atlas.planar("plates", (1, 0, 0), (0, 0, 1))(lid))


def _tint(model, atlas):
    piece = mapkit.tint(model)
    place(piece, tints.ring(atlas, OUTER - 0.02, 0.06, 0.02, sides=8), (0, 0, HEIGHT))
    place(piece, tints.banner(atlas, 0.34, 0.22), (-OUTER - 0.01, -0.12, 0.34), (0, 0, 0))
