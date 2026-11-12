"""The line (Tier2): a belt carrying ore up out of the collar to a hopper on
legs, a control cab on stilts with its windows lit blue, a second pressure
tank, and floodlamps on the rig."""

from catalog import colors
from catalog.ore_extractor import plant
from catalog.ore_extractor.rig import AT, PZ, STEEL
from catalog.paints import machined
from catalog.parts import Into, belts, glasshouse, light, place, production, rails
from workshop import shapes
from workshop.colors import linear

ORE = linear("#35578a")
HOPPER = (0.55, 0.22)
CAB = (-0.5, -0.42)


def line(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    start = (AT[0] + 0.2, AT[1] + 0.05, PZ + 0.14)
    place(into, belts.conveyor(atlas, rng, start, (HOPPER[0] - 0.05, HOPPER[1] + 0.02, PZ + 0.52), ORE,
                               "blue", seed=90))
    place(into, production.hopper(atlas, 0.3, 0.26, 0.2, STEEL, ORE, seed=91), (*HOPPER, PZ))
    place(into, belts.chunks(atlas, rng, 7, (0.1, 0.08), ORE, "blue", 0.05), (HOPPER[0] + 0.05, HOPPER[1] - 0.3, PZ))
    _cab(into, atlas)
    plant.capsule(into, atlas, (0.2, -0.7), 0.08, 0.26, 92)
    for k, x in enumerate((-0.17, 0.0, 0.17)):
        lamp = shapes.cylinder(0.025, 0.05, sides=6, top_radius=0.04)
        place(into, [(lamp, "hull", colors.METAL_DARK, None),
                     (shapes.octahedron(0.024).transform((0, 0, 0.06)), *light(atlas, "white"))],
              (AT[0] + x, AT[1] + 0.12 - 0.1 * (k % 2), PZ + 0.66), (0, 0, 0))


def _cab(into, atlas):
    x, y = CAB
    for sx in (-1, 1):
        for sy in (-1, 1):
            leg = shapes.box((0.025, 0.025, 0.1), bottom=False).transform((x + sx * 0.09, y + sy * 0.08, PZ))
            into.add(leg, "hull", colors.METAL_DARK, atlas.solid("plain")(leg))
    box = shapes.box((0.24, 0.2, 0.15), bevel=0.012, bottom=False).transform((x, y, PZ + 0.1))
    roof = shapes.box((0.28, 0.24, 0.025), bevel=0.008).transform((x, y, PZ + 0.25))
    into.add(box, "hull", machined(colors.HULL, 93, soot=0.2), atlas.fit("plate")(box))
    into.add(roof, "hull", machined(colors.HULL_DARK, 94, soot=0.0), atlas.fit("tread")(roof))
    win = glasshouse.pane_strip(atlas, (0.2, 0.02, 0.07), "panes_blue")
    place(into, win, (x, y - 0.101, PZ + 0.16))
    place(into, rails.ladder(atlas, 0.12, 0.08), (x + 0.14, y - 0.1, PZ))
