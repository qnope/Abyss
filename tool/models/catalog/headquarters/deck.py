"""Life on the gallery's deck: crates and drums stacked against the drum, a
deck hatch, and a ladder down to the plinth on the back left diagonal."""

import math

from catalog import colors
from catalog.headquarters.bridge import DRUM, GALLERY
from catalog.headquarters.keep import PLINTH, radius_at
from catalog.parts import Into, place, props, rails
from workshop import shapes

# On the deck: (maker, angle in degrees, distance, turn).
CARGO = (("crate", 150, 0.86, 0.3), ("crate", 163, 0.88, -0.2), ("drum", 140, 0.92, 0),
         ("drum", 172, 0.93, 0), ("crate", 30, 0.86, 0.5), ("drum", 18, 0.92, 0))


def deck(model, group):
    atlas, into = model.atlas, Into(model, group)
    top = GALLERY[1] + GALLERY[2]
    for k, (maker, angle, distance, turn) in enumerate(CARGO):
        a = math.radians(angle)
        if maker == "crate":
            parts = props.crate(atlas, (0.14, 0.12, 0.1), seed=60 + k)
        else:
            parts = props.drum(atlas, 0.045, 0.11, seed=60 + k)
        place(into, parts, (distance * math.cos(a), distance * math.sin(a), top), (0, 0, a + turn))
    hatch = shapes.box((0.16, 0.16, 0.025), bevel=0.006, bottom=False)
    a = math.radians(-100)
    place(into, [(hatch, "hull", colors.STONE, atlas.fit("door")(hatch))],
          ((DRUM[0] + 0.17) * math.cos(a), (DRUM[0] + 0.17) * math.sin(a), top), (0, 0, a))
    a = math.radians(225)
    foot = radius_at(PLINTH[1]) + 0.04
    place(into, rails.ladder(atlas, top - PLINTH[1] + 0.12),
          (foot * math.cos(a), foot * math.sin(a), PLINTH[1]), (0, 0, a + math.pi / 2))
