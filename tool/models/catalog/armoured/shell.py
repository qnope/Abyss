"""The isopod's armour: a head shield, six domed plates that overlap like a
roof, a tail shield with its two paddle-like uropods, and the spikes and
ember studs along its back."""

from catalog import monster_palette as pal
from catalog.parts import creature, creature_paint
from workshop.colors import linear

Z = 0.22  # the axis of the shell above the floor
PITCH = 0.17  # of the plates
CARAPACE = linear("#6b5a7c")
RIDGE = linear("#b08e68")
HEAD = linear("#594968")
SPIKE = linear("#d2b88c")
GROUP = "Armoured"
WIDTHS = [0.44, 0.5, 0.54, 0.55, 0.5, 0.42]


def plates(model):
    """Six plates from the head back: the first three ride the Front bone, the
    rest the Rear, as one roof."""
    shell = creature_paint.banded(CARAPACE, RIDGE, 1, PITCH, 5)
    mapping = model.atlas.tiled("plates", 0.5)
    for i, width in enumerate(WIDTHS):
        front = PITCH * (3 - i)
        spine = [(0, front, Z), (0, front - 0.09, Z), (0, front - 0.2, Z)]
        piece = creature.loft(spine, [width * 0.86, width, width * 0.93], [0.17, 0.235, 0.2],
                              sides=12, caps=(False, False))
        model.add(GROUP, piece, "shell", shell, uv=mapping, bone="Front" if i < 3 else "Rear")
        _spikes(model, i, front, width)


def _spikes(model, i, front, width):
    """A crest spine on the back of a plate, a thorn at each flank, an ember stud."""
    bone = "Front" if i < 3 else "Rear"
    crest = creature.spikes([(0, front - 0.1, Z + 0.2)], [(0, front - 0.17, Z + 0.36)], 0.04, 5)
    model.add(GROUP, crest, "shell", SPIKE, bone=bone)
    sides = [(s * width * 0.93, front - 0.12, Z + 0.02) for s in (1, -1)]
    thorns = creature.spikes(sides, [(s * (width + 0.2), front - 0.24, Z + 0.0) for s in (1, -1)],
                             0.045, 4)
    model.add(GROUP, thorns, "shell", SPIKE, bone=bone)
    creature.glow(model, GROUP, "ember", creature.dots([(0, front - 0.07, Z + 0.225)], 0.03), bone)


def head(model):
    """The head shield, its two ember eyes, its hooked mandibles."""
    skull = creature_paint.banded(HEAD, RIDGE, 1, PITCH, 9)
    spine = [(0, y, Z) for y in (0.51, 0.62, 0.78, 0.9)]
    shield = creature.loft(spine, [0.4, 0.4, 0.3, 0.13], [0.2, 0.23, 0.19, 0.1], sides=12,
                           caps=(False, True))
    model.add(GROUP, shield, "shell", skull, uv=model.atlas.tiled("plates", 0.5), bone="Head")
    creature.add_eyes(model, GROUP, "eye_ember", (0.28, 0.68, Z + 0.12), 0.11, "Head", toe=50, flat=0.5)
    hooks = creature.spikes([(s * 0.09, 0.88, Z - 0.1) for s in (1, -1)],
                            [(s * 0.03, 1.12, Z - 0.1) for s in (1, -1)], 0.05, 5)
    model.add(GROUP, hooks, "shell", pal.BONE, bone="Head")


def tail(model):
    """The tail shield and the two uropods, a paddle each side."""
    spine = [(0, y, Z - 0.03) for y in (-0.51, -0.66, -0.8, -0.93)]
    shield = creature.loft(spine, [0.42, 0.34, 0.2, 0.07], [0.15, 0.15, 0.11, 0.05], sides=12,
                           caps=(False, True))
    shell = creature_paint.banded(CARAPACE, RIDGE, 1, PITCH, 11)
    model.add(GROUP, shield, "shell", shell, uv=model.atlas.tiled("plates", 0.5), bone="Rear")
    for s in (1, -1):
        paddle = creature.loft([(s * 0.1, -0.9, 0.1), (s * 0.28, -1.05, 0.08), (s * 0.46, -1.22, 0.06)],
                               [0.14, 0.15, 0.04], [0.03, 0.03, 0.015], sides=6)
        model.add(GROUP, paddle, "shell", shell, bone="Fan")
