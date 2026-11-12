"""The Eclaireur (SCOUT): the army's fast, light diver, in blue. A small figure
(0.8 m) with the biggest helmet of the six, a wide cyan visor, an antenna with a
red bulb, a thruster pack with swept dorsal fins and a cyan flame, long
flippers, a gadget on one forearm and a shock prod in the hand. It flees
instead of dying: it swims low and fast, and strikes by lunging in.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog import colors
from catalog.scout import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "scout"
SEED = 7101
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=1_800, materials=3, texture_px=256, bones=14, keyframes=1_400)
NODES = ["Rig"]
GROUP = "Scout"
BUILD = body.Build(leg=0.21, torso=0.22, head=0.19, shoulder=0.15, hip=0.065, upper=0.11,
                   fore=0.11, splay=22, swing=12, bend=38)
BLUE, LIGHT, DEEP = linear("#2a5fd6"), linear("#79adff"), linear("#1b3f9a")
SILVER, NAVY = linear("#aebccb"), linear("#3a4d6e")


def build(model):
    atlas = model.atlas
    dress = looks.Dress(model, GROUP)
    rig = model.rig
    body.humanoid(rig, BUILD)
    suit, plate = looks.suit(atlas, BLUE, SEED), looks.metal(atlas, LIGHT, SEED)
    metal, deep = looks.metal(atlas, SILVER, SEED), looks.suit(atlas, DEEP, SEED + 1)
    cyan, red = looks.lamp(atlas, "cyan"), looks.lamp(atlas, "red")
    diver.legs(dress, BUILD, suit, 0.045)
    diver.arms(dress, BUILD, suit, looks.metal(atlas, NAVY, SEED), 0.04)
    diver.trunk(dress, BUILD, suit, looks.armor(atlas, NAVY, SEED + 2), chest=0.14, waist=0.11)
    diver.helmet(dress, BUILD, looks.metal(atlas, LIGHT, SEED + 3),
                 looks.decal(atlas, "visor", colour=colors.LAMP, material="lamp"), (1, 1, 0.96), (0.7, 0.34, 0.46), 0.0)
    gear.pack(dress, BUILD, metal, deep, cyan)
    gear.flippers(dress, deep, plate)
    gear.head_gear(dress, BUILD, metal, red, metal)
    gear.arms(dress, BUILD, plate, metal, cyan)
    moves.declare(rig)
