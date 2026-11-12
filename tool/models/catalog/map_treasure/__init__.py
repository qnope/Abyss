"""The map's treasure: a sunken chest of salvaged hull plate, its gold-banded
lid thrown open on a glowing heap of gold, coins and cut stones spilled over a
bank of silt. The smallest content of the map (under half a cell high) and
the only one that glows gold: its colour and its open lid tell it from afar.

Not tintable. Front toward -y; the chest stands 0.45 wide on a bank 0.9 wide."""

from catalog import mapkit
from catalog.map_treasure import chest
from catalog.parts import place
from catalog.parts.command import Collector
from catalog.textures import map as tiles

NAME = "map_treasure"
SEED = 7101
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("bullion", "gold", "pink", "cyan", "green", "weathered", "stone", "coral")
BUDGET = mapkit.budget(2_500)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
SMALL = 0.72


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    chest.bank(into, atlas, rng)
    box = Collector()  # the chest is shrunk, to stay the smallest content of the map
    chest.chest(box, atlas)
    place(into, box.parts, scale=SMALL)
    chest.spill(into, atlas, rng)
