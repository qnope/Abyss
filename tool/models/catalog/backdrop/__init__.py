"""The decor round the map of a level: its rim (the sea floor falling away
from the slab the grid stands on) in two straight pieces and a corner the game
repeats round the map, with a reef (or silt, or ash) growing on the shelf,
and the big silhouettes standing beyond. level.py lays a model out; rim.py,
shelf.py and silhouettes.py make the pieces."""

from catalog import palette
from workshop.occlusion import Occlusion

MATERIALS = [palette.ROCK, palette.CORAL, palette.ALGAE, palette.GLOW]
OCCLUSION = Occlusion(rays=16, distance=1.0, floor=0.35,
                      strength={"coral": 0.55, "algae": 0.45, "glow": 0.0})
