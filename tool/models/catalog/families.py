"""The caps of each family of models: what a script's BUDGET must stay within
(families_test.py). Mobile and WebGL 2 first: the figures of the buildings are
the prototype's, which ran smooth on an iPhone; the others are first guesses,
reasoned in README.md ("Budgets"), to be tightened by the bench of each lot
(`?bench=1`).

    triangles    drawn for one model, a mesh counted once per node showing it
    materials    one draw call each, per mesh
    texture_px   the side of its atlas, 0 for vertex colours alone
    bones        of its skeleton
    keyframes    of all its actions: the times of every animation sampler
"""

from workshop.budget import Budget

FAMILIES = {
    # One of eleven on the island, seen up close: the prototype's headquarters.
    "building": Budget(triangles=20_000, materials=5, texture_px=1024),
    # A squad draws several figures of six types on the parade ground.
    "unit": Budget(triangles=3_000, materials=3, texture_px=256, bones=24, keyframes=3_000),
    # A few on a map's cell or in a fight; the Kraken and the Leviathan are the big ones.
    "monster": Budget(triangles=8_000, materials=4, texture_px=512, bones=40, keyframes=6_000),
    # What stands on the cells of a map: dozens of them are drawn at once.
    "map": Budget(triangles=6_000, materials=4, texture_px=512),
    # What is drawn once for a whole scene: the island, its rampart, terrain, backdrops.
    "decor": Budget(triangles=80_000, materials=10, texture_px=512),
}
