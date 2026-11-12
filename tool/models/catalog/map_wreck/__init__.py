"""The wreck: a sunken ship lying heeled over on a bank of silt, the hull of
rusted orange plate split open on the deck, its black hold bridged by bent
ribs, a stern cabin with one lit porthole, a snapped mast and a funnel. The
long diagonal silhouette (0.95 long) and the rust orange tell it from the
rounder, redder lairs; it is the content that shows through the fog.

Not tintable. Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.parts import bank, extrude, fronds, place
from catalog.parts.command import Collector
from catalog.textures import map as tiles
from workshop import noise, shapes, sweep
from workshop.colors import linear, mix, scale

NAME = "map_wreck"
SEED = 7701
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("amber", "teal", "weathered", "stone")
BUDGET = mapkit.budget(3_500)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
RUST = linear("#b8663c")
RUST_DARK = linear("#6e3a28")
ALGAE = linear("#2f7a5a")
LENGTH, DECK = 0.95, 0.3
HEEL, YAW, SINK = math.radians(24), math.radians(-22), 0.07


def rusted(seed, base=RUST):
    def paint(p, normal):
        mottle = noise.fbm(p * 6, seed, octaves=2)
        colour = mix(scale(base, 0.8 + 0.3 * mottle), RUST_DARK, 0.4 if normal.z < 0.3 else 0.0)
        return mix(colour, ALGAE, max(0.0, 0.35 - p.z * 1.5) * 0.7)
    return paint


def hull():
    """The hull: a U in section, pinched at the bow (+x) and the stern."""
    outline = [(0.0, 0.0), (0.1, 0.01), (0.19, 0.12), (0.22, DECK), (-0.22, DECK), (-0.19, 0.12), (-0.1, 0.01)]
    body = extrude.along_x(outline, LENGTH).subdivide(0.13)

    def pinch(p):
        t = p.x / (LENGTH / 2)
        k = 1 - (max(t, 0.0) ** 2.2) * 0.85 - (max(-t, 0.0) ** 3) * 0.3
        return (0, (k - 1) * p.y, (k - 1) * (p.z - 0.1) * 0.6 + max(t, 0.0) ** 2 * 0.07)
    return body.displace(pinch)


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    bank.bank(into, atlas, 0.5, 0.05, linear("#a99a7c"), seed=11)
    ship = Collector()
    body = hull()
    ship.add(body, "hull", rusted(3), atlas.tiled("weathered", 0.5)(body))
    hold = shapes.box((0.36, 0.26, 0.02)).transform((-0.02, 0, DECK))
    ship.add(hold, "hull", (0.01, 0.008, 0.01), atlas.solid("plain")(hold))
    for k in range(6):  # bent ribs across the hold, broken off on one side
        x = -0.17 + 0.07 * k
        reach = 2.6 if k % 2 else 3.14
        rib = sweep.tube([(x, 0.15 * math.cos(a), DECK + 0.1 * math.sin(a)) for a in (reach * t / 5 for t in range(6))],
                         [0.016] * 6, sides=5)
        ship.add(rib, "hull", rusted(k), atlas.solid("plain")(rib))
    cabin = shapes.box((0.2, 0.25, 0.15), bevel=0.01, bottom=False).transform((-0.3, 0, DECK))
    ship.add(cabin, "hull", rusted(9, scale(RUST, 1.15)), atlas.tiled("weathered", 0.4)(cabin))
    port = shapes.cylinder(0.03, 0.012, sides=8, smooth=False).transform((-0.3, -0.13, DECK + 0.08), (math.pi / 2, 0, 0))
    ship.add(port, "lamp", colors.LAMP, atlas.solid("amber")(port))
    mast = shapes.cylinder(0.025, 0.36, sides=6, top_radius=0.016, smooth=False, bottom=False).transform((0.12, 0, DECK - 0.02), (0.15, 0.1, 0))
    ship.add(mast, "hull", RUST_DARK, atlas.solid("plain")(mast))
    beam = shapes.box((0.22, 0.02, 0.02)).transform((0.14, 0, DECK + 0.27), (0, 0.15, 0.1))
    ship.add(beam, "hull", RUST_DARK, atlas.solid("plain")(beam))
    funnel = shapes.cylinder(0.05, 0.16, sides=8, top_radius=0.04, smooth=False, bottom=False).transform((-0.3, 0.02, DECK + 0.14))
    ship.add(funnel, "hull", rusted(5, scale(RUST, 0.8)), atlas.solid("plain")(funnel))
    place(into, ship.parts, (0, 0, SINK), (HEEL, 0, YAW))
    for k in range(4):
        a = 2 * math.pi * k / 4 + 0.3
        place(into, fronds.tuft(atlas, rng, 0.16, colors.KELP_DARK), (0.4 * math.cos(a), 0.36 * math.sin(a), 0.03))
