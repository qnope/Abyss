"""Le Saboteur (SABOTEUR): the army's glass cannon, in dark green with a mint
glow. A small, hunched figure (0.8 m) wrapped in a hooded cloak with a ragged
hem and a pointed hood tail, a gas mask with two red lenses and a green filter,
wrapped legs, a filter canister on its back, a dagger in its right fist and on
its left hip a limpet mine ringed in green: the thing it places on a target to
ignore its defence. It crouches, swims flat and fast, and strikes by unclipping
the mine and pressing it on.

One figure of a squad: origin on the floor under it, facing +Y (Godot's -Z)."""

from catalog.saboteur import gear, moves
from catalog.textures import units
from catalog.unit_kit import MATERIALS, OCCLUSION, body, diver, forms, looks
from workshop.budget import Budget
from workshop.colors import linear

NAME = "saboteur"
SEED = 7106
FAMILY = "unit"
PORTRAIT = True
ATLAS = units.atlas()
BUDGET = Budget(triangles=2_200, materials=3, texture_px=256, bones=15, keyframes=1_700)
NODES = ["Rig"]
GROUP = "Saboteur"
BUILD = body.Build(leg=0.21, torso=0.22, head=0.17, shoulder=0.15, hip=0.07, upper=0.12,
                   fore=0.12, splay=16, swing=22, bend=55, stoop=0.05)
CLOAK, HEM, SUIT = linear("#5aa586"), linear("#69f0ae"), linear("#667a72")
RUBBER, STEEL, MINT = linear("#6c7e79"), linear("#b3c1bd"), linear("#69f0ae")


def build(model):
    atlas, rig = model.atlas, model.rig
    dress = looks.Dress(model, GROUP)
    body.humanoid(rig, BUILD)
    gear.mine_bone(rig, BUILD)
    suit, cloth = looks.suit(atlas, SUIT, SEED), looks.suit(atlas, CLOAK, SEED + 1)
    hem, rubber = looks.suit(atlas, HEM, SEED + 2), looks.metal(atlas, RUBBER, SEED + 3)
    steel, strap = looks.metal(atlas, STEEL, SEED + 4), looks.metal(atlas, MINT, SEED + 5)
    green, red = looks.lamp(atlas, "green"), looks.lamp(atlas, "red")
    diver.legs(dress, BUILD, suit, 0.042)
    diver.arms(dress, BUILD, suit, rubber, 0.038)
    diver.trunk(dress, BUILD, suit, rubber, chest=0.13, waist=0.1)
    gear.cloak(dress, BUILD, cloth, hem)
    gear.runes(dress, BUILD, green)
    gear.boots(dress, rubber)
    gear.hood(dress, BUILD, cloth, rubber, red, green, rubber)
    gear.wraps(dress, BUILD, strap)
    gear.canister(dress, BUILD, steel, green)
    gear.mine(dress, looks.metal(atlas, linear("#46524f"), SEED + 6), green, red)
    gear.dagger(dress, BUILD, steel, green)
    moves.declare(rig)
