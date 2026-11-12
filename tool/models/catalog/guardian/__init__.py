"""Le Gardien (GUARDIAN): the army's heavy defender, in steel and white with a
cyan glow. A broad figure (1.0 m, almost as wide as it is tall once the shield
is counted) in a great helm with a glowing slit and a crest, big pauldrons, a
breastplate and greaves, and on its left arm a tower shield nearly its own
height bearing the colony's emblem: the monsters strike it first. A maul in the
right hand. It strikes with a shield bash.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog.guardian import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, forms, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "guardian"
SEED = 7103
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=2_200, materials=3, texture_px=256, bones=14, keyframes=1_700)
NODES = ["Rig"]
GROUP = "Guardian"
BUILD = body.Build(leg=0.26, torso=0.31, head=0.2, shoulder=0.25, hip=0.1, upper=0.14,
                   fore=0.14, splay=20, swing=10, bend=45)
STEEL, WHITE_STEEL, DARK_STEEL = linear("#8e9cac"), linear("#c6d0db"), linear("#4a5b70")
SUIT = linear("#46586d")


def build(model):
    atlas, rig = model.atlas, model.rig
    dress = looks.Dress(model, GROUP)
    body.humanoid(rig, BUILD)
    suit = looks.suit(atlas, SUIT, SEED)
    steel, white = looks.metal(atlas, STEEL, SEED), looks.armor(atlas, WHITE_STEEL, SEED + 1)
    dark = looks.metal(atlas, DARK_STEEL, SEED + 2)
    cyan = looks.lamp(atlas, "cyan")
    diver.legs(dress, BUILD, suit, 0.055)
    diver.arms(dress, BUILD, suit, dark, 0.05)
    diver.trunk(dress, BUILD, looks.suit(atlas, DARK_STEEL, SEED + 3), dark, chest=0.2, waist=0.15)
    dress.add(forms.ball(BUILD.head_centre(), BUILD.head, (1.05, 1.0, 1.0), 2),
              looks.metal(atlas, WHITE_STEEL, SEED + 4), "Head")
    gear.helm(dress, BUILD, steel, cyan, dark)
    gear.armour(dress, BUILD, looks.metal(atlas, WHITE_STEEL, SEED + 5), white, steel, cyan)
    gear.shield(dress, BUILD, white, dark, looks.decal(atlas, "emblem"), cyan)
    gear.maul(dress, BUILD, dark, steel, cyan)
    gear.back(dress, BUILD, white, steel, cyan)
    moves.declare(rig)
