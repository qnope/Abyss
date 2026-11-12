"""The fog over the cells of the map not seen yet: a murk of soft translucent
sheets the game lays on each hidden cell and lifts when a scout sees it.

    Cloud1..Cloud3   a cell's shroud: three stacked sheets of murk, a cell and
                     a little over each side so that neighbours merge into one
                     blanket, nearly opaque inside the cell and dissolving at
                     its border, its crest 0.16 over the floor (y = 0), its
                     body dark and its crest paler and thinner
    Wisp1..Wisp3     a loose puff 0.6 wide, for the edge where a cell is
                     lifted: the game lets them drift off the dissolving
                     cloud, grow and fade out

Each node's mesh is centred on its origin, its floor at y = 0; the nodes stand
apart for review only. Translucent: one material, `murk`, drawn blended with
the alpha of its vertex colours. The game fades a node with its
`transparency` and scales it, and should not let it cast a shadow."""

from catalog.seabed import murk
from workshop.budget import Budget
from workshop.colors import linear, mix
from workshop.materials import Material
from workshop.occlusion import Occlusion

NAME = "map_fog"
SEED = 71
FAMILY = "map"
MURK = Material("murk", roughness=1.0, translucent=True)
MATERIALS = [MURK]
OCCLUSION = Occlusion(rays=4, strength={"murk": 0.0})
BUDGET = Budget(triangles=3_000, materials=1)
NODES = [f"Cloud{k}" for k in (1, 2, 3)] + [f"Wisp{k}" for k in (1, 2, 3)]

DEEP, PALE = linear("#142234"), linear("#46607a")
# The sheets of a cloud: (half width, lift, crest share, alpha). A cell's own is
# 0.5; the lowest overspills it so that neighbours merge, the upper ones are
# paler and thinner, and their swell is what the eye reads as depth.
LAYERS = ((0.85, -0.03, 0.0, 0.9), (0.75, 0.07, 0.5, 0.6), (0.65, 0.15, 1.0, 0.45))
SPACING = 1.8


def cloud(model, path, location, seed):
    piece = model.piece(path, location)
    for k, (half, lift, share, alpha) in enumerate(LAYERS):
        geometry, colours = murk.sheet(half, seed + 3 * k, mix(DEEP, PALE, share * 0.6),
                                       mix(DEEP, PALE, 0.3 + share * 0.7), alpha, half * 0.75)
        geometry.transform((0, 0, lift))
        piece.add(geometry, "murk", colours)


def wisp(model, path, location, seed):
    piece = model.piece(path, location)
    geometry, colours = murk.dome(0.34, 0.1, seed, mix(DEEP, PALE, 0.5), PALE, (0.4, 0.35, 0.18, 0.0), 0.3)
    geometry.transform((0, 0, 0.12), (0, 0, model.rng.uniform(0, 6.28)))
    piece.add(geometry, "murk", colours)


def build(model):
    for k in range(3):
        cloud(model, f"Cloud{k + 1}", (k * SPACING, 0.0, 0.0), SEED + 10 * k)
        wisp(model, f"Wisp{k + 1}", (k * SPACING, -SPACING, 0.0), SEED + 100 + 10 * k)
