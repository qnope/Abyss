"""The Harponneur (HARPOONIST): the army's ranged fighter, in red and brass. A
classic deep-sea diver of 1.1 m: a round brass helmet with three amber ports
and a corselet collar, a red canvas suit, twin air tanks on its back with a hose
looping to the helmet, lead-soled boots and, held up and forward in its right
hand, a harpoon taller than itself with a barbed iron head. It levels the
harpoon to swim, and strikes by twisting back and thrusting it ahead.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog import colors
from catalog.harpoonist import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, forms, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "harpoonist"
SEED = 7102
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=2_400, materials=3, texture_px=256, bones=14, keyframes=1_700)
NODES = ["Rig"]
GROUP = "Harpoonist"
BUILD = body.Build(leg=0.29, torso=0.29, head=0.2, shoulder=0.19, hip=0.085, upper=0.14,
                   fore=0.135, splay=16, swing=12, bend=48)
RED, DEEP_RED, BRASS = linear("#d8402f"), linear("#8f2a24"), linear("#d4962a")
IRON, WOOD, LEATHER = linear("#8794a3"), linear("#b08048"), linear("#7a5638")


def build(model):
    atlas, rig = model.atlas, model.rig
    dress = looks.Dress(model, GROUP)
    body.humanoid(rig, BUILD)
    suit, dark = looks.suit(atlas, RED, SEED), looks.suit(atlas, DEEP_RED, SEED + 1)
    brass, iron = looks.metal(atlas, BRASS, SEED), looks.metal(atlas, IRON, SEED + 2)
    leather = looks.armor(atlas, LEATHER, SEED + 3, "strap")
    amber = looks.decal(atlas, "porthole", colour=colors.LAMP, material="lamp")
    diver.legs(dress, BUILD, suit, 0.05)
    diver.arms(dress, BUILD, suit, looks.metal(atlas, LEATHER, SEED + 6), 0.047)
    diver.trunk(dress, BUILD, suit, brass, chest=0.16, waist=0.135)
    dress.add(forms.ball(BUILD.head_centre(), BUILD.head, (1, 1, 0.98), 2), brass, "Head")
    gear.helmet(dress, BUILD, brass, amber, iron)
    gear.tanks(dress, BUILD, iron, brass, dark)
    gear.boots(dress, looks.metal(atlas, linear("#5d6b7c"), SEED + 4), dark)
    gear.coil(dress, looks.suit(atlas, linear("#c9b48a"), SEED), leather)
    gear.harpoon(dress, BUILD, looks.metal(atlas, WOOD, SEED + 5), iron, looks.lamp(atlas, "amber"))
    moves.declare(rig)
