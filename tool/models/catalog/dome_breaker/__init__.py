"""Le Briseur (DOME_BREAKER): the army's siege unit, in orange and charcoal. A
hulking diver (0.95 m, the widest of the six): short legs, enormous shoulders,
one pauldron studded with spikes, a horned helmet with a wide amber visor
bar, hazard-striped gauntlets and greaves, a hydraulic pack and, carried on its
right shoulder, the breaching hammer: a heavy flat face with a drill spike
behind it. It strikes by swinging the hammer overhead and slamming it down.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog.dome_breaker import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, forms, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "dome_breaker"
SEED = 7104
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=2_600, materials=3, texture_px=256, bones=14, keyframes=1_800)
NODES = ["Rig"]
GROUP = "DomeBreaker"
BUILD = body.Build(leg=0.23, torso=0.34, head=0.2, shoulder=0.3, hip=0.12, upper=0.17,
                   fore=0.16, splay=26, swing=6, bend=28)
ORANGE, DEEP_ORANGE, CHARCOAL = linear("#f27c00"), linear("#c95800"), linear("#566170")
STEEL, BONE = linear("#8b96a3"), linear("#e8dcc0")


def build(model):
    atlas, rig = model.atlas, model.rig
    dress = looks.Dress(model, GROUP)
    body.humanoid(rig, BUILD)
    suit = looks.suit(atlas, CHARCOAL, SEED)
    orange, deep = looks.metal(atlas, ORANGE, SEED), looks.armor(atlas, DEEP_ORANGE, SEED + 1)
    steel = looks.metal(atlas, STEEL, SEED + 2)
    hazard = looks.armor(atlas, linear("#ffd070"), SEED + 3, "hazard")
    amber = looks.lamp(atlas, "amber")
    diver.legs(dress, BUILD, suit, 0.068)
    diver.arms(dress, BUILD, suit, looks.metal(atlas, CHARCOAL, SEED + 4), 0.058)
    diver.trunk(dress, BUILD, looks.suit(atlas, DEEP_ORANGE, SEED + 5), steel, chest=0.24, waist=0.17,
                depth=0.85)
    dress.add(forms.ball(BUILD.head_centre(), BUILD.head, (1.05, 1.0, 0.98), 2), orange, "Head")
    gear.helmet(dress, BUILD, deep, looks.metal(atlas, BONE, SEED + 6), amber)
    gear.pauldrons(dress, BUILD, orange, orange, looks.metal(atlas, BONE, SEED + 6))
    gear.stripes(dress, BUILD, hazard, deep)
    gear.pack(dress, BUILD, deep, orange, amber)
    gear.hammer(dress, BUILD, steel, deep, steel, amber)
    moves.declare(rig)
