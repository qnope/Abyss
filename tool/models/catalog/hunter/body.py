"""The hunting squid's body: a long pointed mantle with its arrow fins and its
sulfur photophores, and a head with two huge yellow eyes."""

from catalog.parts import creature, creature_paint
from workshop import skin
from workshop.colors import linear

H = 0.65  # the body's axis above the floor
BACK = linear("#8a2f4d")
BELLY = linear("#c46c80")
FIN = linear("#a8405c")
GROUP = "Hunter"
TIP = [(0, -0.3, H), (0, -0.65, H), (0, -1.0, H)]


def skeleton(rig):
    """Body (the front of the mantle), Head, the mantle's two tip bones and
    the two fins' bones; gives the tip's names."""
    rig.bone("Body", None, (0, -0.3, H), (0, 0.1, H))
    rig.bone("Head", "Body", (0, 0.1, H), (0, 0.45, H))
    for name, side in (("FinR", 1), ("FinL", -1)):
        rig.bone(name, "Body", (side * 0.2, -0.65, H), (side * 0.45, -0.65, H))
    return rig.chain("Tip", "Body", TIP)


def shape(model, tip):
    """The mantle in two parts (a rigid front, a tail that blends along the
    tip's bones), the fins, the head, its eyes and the lights along the flanks."""
    rig, atlas = model.rig, model.atlas
    skin_tile = atlas.tiled("skin", 0.4)
    colour = creature_paint.shaded(BACK, BELLY, H, 0.24, 21, 0.18)
    front = creature.loft([(0, y, H) for y in (-0.3, -0.15, 0.0, 0.1)], [0.26, 0.27, 0.25, 0.2],
                          [0.22, 0.23, 0.22, 0.18], sides=12, caps=(False, False))
    model.add(GROUP, front, "flesh", colour, uv=skin_tile, bone="Body")
    rear = creature.loft([(0, y, H) for y in (-1.15, -0.95, -0.7, -0.45, -0.3)],
                         [0.02, 0.1, 0.2, 0.25, 0.26], [0.02, 0.09, 0.17, 0.21, 0.22], sides=12,
                         caps=(True, False))
    along = skin.along(tip, rig.centres(tip))
    model.add(GROUP, rear, "flesh", colour, uv=skin_tile, bone=along)
    head = creature.loft([(0, y, H) for y in (0.08, 0.2, 0.34, 0.46)], [0.2, 0.23, 0.18, 0.12],
                         [0.18, 0.2, 0.16, 0.1], sides=12, caps=(False, True))
    model.add(GROUP, head, "flesh", colour, uv=skin_tile, bone="Head")
    creature.add_eyes(model, GROUP, "eye_sulfur", (0.2, 0.26, H + 0.03), 0.12, "Head", toe=35, flat=0.65)
    _fins(model)
    _lights(model)


def _fins(model):
    solid = model.atlas.solid("plain")
    for name, side in (("FinR", 1), ("FinL", -1)):
        points = [(side * 0.18, -0.46, H), (side * 0.46, -0.78, H - 0.02), (side * 0.4, -1.02, H - 0.02),
                  (side * 0.1, -1.0, H)]
        model.add(GROUP, creature.membrane(points), "membrane", FIN, uv=solid, bone=name)
        rib = [(side * 0.18, -0.46, H), (side * 0.46, -0.78, H - 0.02)]
        model.add(GROUP, creature.spikes(rib[:1], rib[1:], 0.025, 4), "shell", BELLY, bone=name)


def _lights(model):
    """Photophores in two rows down the flanks and a pair on the brow."""
    flank = [(s * 0.25, y, H - 0.06) for s in (1, -1) for y in (-0.28, -0.18, -0.08, 0.02)]
    creature.glow(model, GROUP, "sulfur", creature.dots(flank, 0.028), "Body")
    brow = [(s * 0.1, 0.38, H + 0.12) for s in (1, -1)]
    creature.glow(model, GROUP, "sulfur", creature.dots(brow, 0.03), "Head")
