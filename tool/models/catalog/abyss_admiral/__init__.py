"""L'Amiral des Abysses (ABYSS_ADMIRAL): the commander of the fleet, in violet
and gold. The tallest of the six (1.45 m), slender, in a long violet coat whose
flared tails hang on two bones of their own, tall boots with gold bands, gold
buttons, epaulettes with fringe and a medal, a round helm with a violet visor
under a gold-trimmed bicorne, a comms mast with a violet light on its back and,
in its right hand, the gold baton of command. It does not fight: its attack is
the order, the baton raised high and swept down at the foe.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog.abyss_admiral import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, forms, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "abyss_admiral"
SEED = 7105
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=2_600, materials=3, texture_px=256, bones=16, keyframes=2_100)
NODES = ["Rig"]
GROUP = "AbyssAdmiral"
BUILD = body.Build(leg=0.5, torso=0.42, head=0.19, shoulder=0.2, hip=0.085, upper=0.18,
                   fore=0.17, splay=11, swing=4, bend=50)
VIOLET, DEEP, GOLD = linear("#a04fe0"), linear("#5a2a96"), linear("#e8b83a")
GLOVE, LEATHER, HELM = linear("#e8e4f4"), linear("#3b2a52"), linear("#cdbff0")


def build(model):
    atlas, rig = model.atlas, model.rig
    dress = looks.Dress(model, GROUP)
    body.humanoid(rig, BUILD)
    gear.coat_bones(rig)
    cloth, deep = looks.suit(atlas, VIOLET, SEED), looks.suit(atlas, DEEP, SEED + 1)
    gold, glove = looks.metal(atlas, GOLD, SEED + 2), looks.metal(atlas, GLOVE, SEED + 3)
    leather = looks.metal(atlas, LEATHER, SEED + 4)
    diver.legs(dress, BUILD, deep, 0.05)
    diver.arms(dress, BUILD, cloth, glove, 0.045)
    diver.trunk(dress, BUILD, cloth, gold, chest=0.17, waist=0.14)
    dress.add(forms.ball(BUILD.head_centre(), BUILD.head, (1, 1, 0.98), 2), looks.metal(atlas, HELM, SEED + 5), "Head")
    gear.coat(dress, BUILD, cloth, deep, gold)
    gear.uniform(dress, BUILD, looks.lamp(atlas, "gold"), gold)
    gear.boots(dress, BUILD, leather, gold)
    gear.hat(dress, BUILD, deep, gold, looks.lamp(atlas, "gold"), looks.lamp(atlas, "violet"))
    gear.mast(dress, BUILD, gold, looks.lamp(atlas, "violet"))
    gear.baton(dress, BUILD, gold, looks.lamp(atlas, "gold"))
    moves.declare(rig)
