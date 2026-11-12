"""A level's sea floor: its palette, the grain it shares between tiles and
the recipes of its variants, and how the model lays them out. The model
holds the tiles as nodes in two rows, lit above and under the fog below, a
cell and a half apart: the game takes each node's mesh and places it on a
cell (the node's own place is for review only)."""

from dataclasses import dataclass

from catalog import palette
from catalog.seabed.tile import Tile
from workshop.materials import Material
from workshop.occlusion import Occlusion

SEABED = Material("seabed", roughness=0.9, textured=True)
MATERIALS = [SEABED, palette.GLOW]
OCCLUSION = Occlusion(rays=16, distance=0.4, floor=0.45, strength={"seabed": 0.85, "glow": 0.0})
FOG_DROP = 0.2  # how far under the floor a tile not seen lies (TerrainLook.FOG_DROP)
SPACING = 1.6


@dataclass(frozen=True)
class Level:
    """[sand], [patch] and [wall] colour the ground, its mottling and the
    slab's sides; [fog_sand] and [fog_patch] the ground under the fog.
    [ripple] is (i, j, height) of the ripples every tile shares; [look] is
    what the atlas paints; [lit] and [hidden] are the recipes of the
    variants, functions of a Tile."""

    number: int
    seed: int
    sand: tuple
    patch: tuple
    wall: tuple
    fog_sand: tuple
    fog_patch: tuple
    ripple: tuple
    look: dict
    lit: tuple
    hidden: tuple


def nodes(level):
    """The nodes a level's model holds, for its script's NODES."""
    return ([f"Lit{k + 1}" for k in range(len(level.lit))]
            + [f"Fog{k + 1}" for k in range(len(level.hidden))])


def lay(model, level):
    """Builds every variant of [level] into [model]: Lit1.., Fog1.."""
    for row, (kind, recipes) in enumerate((("Lit", level.lit), ("Fog", level.hidden))):
        for k, recipe in enumerate(recipes):
            lit = kind == "Lit"
            tile = Tile(model, level, f"{kind}{k + 1}", (k * SPACING, -row * SPACING, 0.0),
                        level.seed * 10 + 3 * k + row, 0.0 if lit else -FOG_DROP,
                        f"lit{k + 1}" if lit else f"fog{k + 1}")
            recipe(tile)
