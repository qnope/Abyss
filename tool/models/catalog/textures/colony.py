"""The tiles every colony building shares, laid out on a 16 x 16 grid (64 px
cells in a 1024 px atlas). The rows from 6 down, but the coral's corner,
are left to each building's own tiles (atlas(extra))."""

from catalog.textures import lights, living, metal, solar
from catalog.textures.lights import AMBER, CYAN, DARK, GOLD, PINK, WHITE
from workshop.atlas import Atlas, Tile

COLONY = {
    "plain": Tile((0, 0, 1, 1), lights.solid((1.0, 1.0, 1.0))),
    "amber": Tile((1, 0, 1, 1), lights.solid(AMBER)),
    "cyan": Tile((2, 0, 1, 1), lights.solid(CYAN)),
    "pink": Tile((3, 0, 1, 1), lights.solid(PINK)),
    "gold": Tile((0, 1, 1, 1), lights.solid(GOLD)),
    "white": Tile((1, 1, 1, 1), lights.solid(WHITE)),
    "dark": Tile((2, 1, 1, 1), lights.solid(DARK)),
    "rust": Tile((3, 1, 1, 1), lights.solid(metal.RUST)),
    "plate": Tile((4, 0, 2, 2), metal.plate),
    "plate_wide": Tile((6, 0, 4, 2), lambda c: metal.plate(c, across=2)),
    "plate_tall": Tile((10, 0, 2, 4), lambda c: metal.plate(c, up=2)),
    "strap": Tile((12, 0, 4, 1), metal.strap),
    "hazard": Tile((12, 1, 2, 1), metal.hazard),
    "vent": Tile((14, 1, 2, 2), metal.vent),
    "weathered": Tile((0, 2, 4, 4), metal.weathered, seamless=True),
    "tread": Tile((4, 2, 2, 2), metal.tread),
    "panes_amber": Tile((6, 2, 2, 2), lights.panes(AMBER)),
    "porthole_amber": Tile((8, 2, 2, 2), lights.porthole(AMBER)),
    "panes_cyan": Tile((12, 2, 2, 2), lights.panes(CYAN, across=3, up=2)),
    "glass": Tile((4, 4, 2, 2), lights.glass),
    "panes_pink": Tile((6, 4, 2, 2), lights.panes(PINK, across=1, up=3)),
    "porthole_cyan": Tile((8, 4, 2, 2), lights.porthole(CYAN)),
    "ribbon_cyan": Tile((10, 4, 4, 1), lights.ribbon(CYAN)),
    "ribbon_amber": Tile((10, 5, 4, 1), lights.ribbon(AMBER)),
    "porthole_pink": Tile((14, 4, 2, 2), lights.porthole(PINK)),
    "emblem": Tile((10, 6, 2, 2), metal.emblem),
    "bridge": Tile((8, 6, 2, 1), lights.panes(CYAN, across=2, up=1, frame=4.0)),
    "bolt": Tile((14, 3, 1, 1), metal.bolt),
    "door": Tile((15, 3, 1, 1), metal.door),
    "coral": Tile((0, 6, 4, 4), living.coral, seamless=True),
    "solar": Tile((4, 6, 4, 6), solar.cells()),
}


def atlas(extra=None, size=1024, seed=0):
    """The colony's tiles and a building's [extra] ones in one atlas."""
    return Atlas(size, 16, {**COLONY, **(extra or {})}, seed)
