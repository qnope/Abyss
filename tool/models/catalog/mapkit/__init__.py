"""What the models of the map's contents share (not a model itself): each
stands on the floor under the centre of a cell (the volcano on the middle of
its 2 x 2), 1 unit a cell, Blender Z up, its front toward -y (the map's camera
looks from +z in the game, which is -y here).

    Body    the node of every static part, joined per material
    Tint    (some kinds) the part the game recolours: a holder's banner and
            ring, a rival's banner, the volcano's seal. Its own node, one mesh
            of the lamp material in a neutral white, so that the game gives it
            a material of the colour it wants (material_override).

Four materials, one 512 px atlas, no animation: what the family allows."""

from catalog import palette
from catalog.parts import Into
from workshop.budget import Budget
from workshop.occlusion import Occlusion

FAMILY = "map"
MATERIALS = [palette.HULL, palette.REEF, palette.LAMP, palette.GLASS]
OCCLUSION = Occlusion(rays=20, distance=0.35, floor=0.35,
                      strength={"reef": 0.55, "lamp": 0.0, "glass": 0.4})
BODY = "Body"
TINT = "Tint"
FRONT = -1.5707963267948966  # the azimuth facing the map's camera (-y)


def budget(triangles, texture_px=512):
    """The budget of a content: [triangles] of the family's 6 000, its four
    materials, its atlas."""
    return Budget(triangles=triangles, materials=4, texture_px=texture_px)


def body(model):
    """Where the static parts of [model] go."""
    return Into(model, BODY)


def tint(model):
    """The piece the game recolours, to place the parts of the tint into."""
    return model.piece(TINT)
