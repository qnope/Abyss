"""The sleeping shark's head: an underslung jaw of rows of teeth, two heavy-lidded
blood-red eyes, and the glowing slits of its gills."""

import math

from catalog import monster_palette as pal
from catalog.colossus.body import GROUP, skin_paint
from catalog.parts import creature
from workshop import shapes
from workshop.geometry import Geometry


def shape(model):
    paint = skin_paint()
    hide = model.atlas.tiled("hide", 0.7)
    jaw = creature.loft([(0, y, 0.0) for y in (1.0, 1.3, 1.55, 1.72)], [0.4, 0.36, 0.22, 0.05],
                        [0.1, 0.09, 0.06, 0.03], sides=12, caps=(False, True),
                        lift=[0.1, 0.08, 0.07, 0.07])
    model.add(GROUP, jaw, "flesh", paint, uv=hide, bone="Jaw")
    _teeth(model)
    creature.add_eyes(model, GROUP, "eye_blood", (0.43, 1.37, 0.6), 0.12, "Head", toe=70, flat=0.55)
    for name, side in (("LidR", 1), ("LidL", -1)):
        lid = shapes.sphere(0.14, subdivisions=2).transform((side * 0.45, 1.385, 0.68),
                                                            scale=(0.5, 1.2, 0.62))
        model.add(GROUP, lid, "flesh", paint, uv=hide, bone=name)
    _gills(model)


def _teeth(model):
    """Two rows of triangular teeth round the mouth: the upper hang from the
    head's underside, the lower stand on the jaw."""
    arc = [(0.1 + 0.5 * i / 8, math.radians(-80 + 20 * i)) for i in range(9)]
    upper = [(math.sin(a) * 0.38 * (1 - 0.35 * i / 8), 1.05 + 0.6 * i / 8, 0.22)
             for i, (_, a) in enumerate(arc)]
    model.add(GROUP, creature.spikes(upper, [(x * 0.95, y + 0.02, 0.07) for x, y, _ in upper], 0.045, 4),
              "shell", pal.BONE, bone="Head")
    lower = [(x * 0.9, y + 0.03, 0.15) for x, y, _ in upper[1:-1]]
    model.add(GROUP, creature.spikes(lower, [(x * 0.95, y + 0.02, 0.3) for x, y, _ in lower], 0.04, 4),
              "shell", pal.BONE, bone="Jaw")


def _gills(model):
    """Five slits each side behind the head, dull red from within."""
    slits = Geometry()
    for side in (1, -1):
        for i in range(5):
            slit = shapes.octahedron(1.0).transform((side * 0.59, 0.62 - 0.07 * i, 0.58),
                                                    rotation=(0, 0, 0), scale=(0.02, 0.025, 0.2 - 0.02 * i))
            slits.extend(slit)
    creature.glow(model, GROUP, "blood", slits, "Body")
