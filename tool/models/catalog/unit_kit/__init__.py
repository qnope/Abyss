"""What the six units of the army share: one diver's skeleton (body.py) with a
build each, the shapes and looks they are made of (forms.py, looks.py), the
parts every diver has (diver.py), the four actions (actions.py) and one atlas
(textures/units.py). A unit's script is its own proportions, its props and its
attack.

Every unit: family `unit`, three materials (hull for armour and metal, suit for
neoprene and cloth, lamp for every light), one 256 px atlas, a skeleton of
under 24 bones and the actions idle, swim (loops), attack and hit (once)."""

from catalog import palette
from workshop.materials import Material
from workshop.occlusion import Occlusion

SUIT = Material("suit", roughness=0.72, textured=True)
MATERIALS = [palette.HULL, SUIT, palette.LAMP]
# Small round parts: a little occlusion only, or it shows as zigzags on a low-poly helmet.
OCCLUSION = Occlusion(rays=32, distance=0.22, floor=0.55,
                      strength={"suit": 0.8, "hull": 0.6, "lamp": 0.0})
