"""The Léviathan's head: a long skull with swept-back horns, two ghostly eyes,
and a hinged jaw hung with fangs."""

from catalog import monster_palette as pal
from catalog.leviathan.body import BACK, BELLY, GROUP, HEAD_BASE
from catalog.parts import creature, creature_paint
from workshop.colors import linear

HORN = linear("#b8b08c")
SCAR = linear("#a9c9a8")
Z = HEAD_BASE[2]  # the height of the skull's axis
Y = HEAD_BASE[1]  # where the skull starts


def shape(model):
    hide = model.atlas.tiled("hide", 1.6)
    paint = creature_paint.shaded(BACK, BELLY, Z, 0.8, 73, 0.12, 1.2, (SCAR, 1.0))
    ys = [Y + d for d in (-0.1, 0.55, 1.2, 1.75, 2.05)]
    skull = creature.loft([(0, y, 0.0) for y in ys], [1.0, 1.15, 0.95, 0.6, 0.1],
                          [0.85, 0.8, 0.6, 0.42, 0.07], sides=16, caps=(False, True),
                          lift=[Z + 0.05, Z + 0.1, Z + 0.05, Z - 0.03, Z - 0.1])
    model.add(GROUP, skull, "flesh", paint, uv=hide, bone="Head")
    jaw = creature.loft([(0, y + 0.1, 0.0) for y in ys], [0.85, 0.8, 0.6, 0.34, 0.07],
                        [0.24, 0.24, 0.18, 0.12, 0.05], sides=12, caps=(False, True),
                        lift=[Z - 0.65, Z - 0.7, Z - 0.72, Z - 0.7, Z - 0.65])
    model.add(GROUP, jaw, "flesh", paint, uv=hide, bone="Jaw")
    _fangs(model)
    _horns(model)
    creature.add_eyes(model, GROUP, "eye_pale", (0.8, Y + 0.6, Z + 0.35), 0.32, "Head", toe=45, flat=0.55)


def _fangs(model):
    """Two rows of long fangs: the upper hang from the skull, the lower stand on the jaw."""
    ys = [Y + 0.55 + 0.2 * i for i in range(8)]
    upper = [(s * (0.78 - 0.07 * i), y, Z - 0.35) for s in (1, -1) for i, y in enumerate(ys)]
    model.add(GROUP, creature.spikes(upper, [(x, y + 0.1, Z - 0.95) for x, y, _ in upper], 0.08, 4),
              "shell", pal.BONE, bone="Head")
    lower = [(s * (0.66 - 0.07 * i), y + 0.1, Z - 0.55) for s in (1, -1) for i, y in enumerate(ys[:7])]
    model.add(GROUP, creature.spikes(lower, [(x, y + 0.08, Z + 0.0) for x, y, _ in lower], 0.07, 4),
              "shell", pal.BONE, bone="Jaw")


def _horns(model):
    """Two great swept-back horns and a lesser pair behind them."""
    bases = [(s * 0.6, Y + 0.3, Z + 0.6) for s in (1, -1)] + [(s * 0.75, Y - 0.05, Z + 0.45) for s in (1, -1)]
    tips = [(s * 1.2, Y - 1.3, Z + 1.5) for s in (1, -1)] + [(s * 1.5, Y - 1.0, Z + 0.8) for s in (1, -1)]
    model.add(GROUP, creature.spikes(bases, tips, 0.2, 6), "shell", HORN, bone="Head")
