"""What the buildings of the descent share: their colours, beams between two
points, rings of lamps, round hatches and swollen rock. Each maker gives parts
as (geometry, material, paint, uv) in the building's frame."""

import math

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import light
from workshop import noise, shapes, sweep
from workshop.colors import linear, scale

# The descent module: grey-green steel. The pressure capsule: white and
# steel blue, a yellow tank. The kernel: black basalt, iron and fire.
GREEN = linear("#9bb8ab")
GREEN_DARK = linear("#6a877c")
GREEN_PALE = linear("#c4dad0")
WHITE = linear("#e6eef4")
STEEL = linear("#4f7ca8")
STEEL_DEEP = linear("#2d4a68")
YELLOW = linear("#e8b730")
BASALT = linear("#3a3542")
BASALT_LIGHT = linear("#5a5466")
IRON = linear("#4a4650")
FRONT = -math.pi / 4  # the azimuth facing the game's camera and the headquarters


def beam(atlas, a, b, width, colour, seed=0, depth=None, tile="plates", period=0.5, material="hull"):
    """A bevelled bar from [a] to [b] (x, y, z), [width] by [depth] across."""
    a, b = Vector(a), Vector(b)
    bar = shapes.box((width, depth or width, (b - a).length), bevel=min(0.01, width / 4))
    bar.apply((b - a).normalized().to_track_quat("Z", "Y").to_matrix().to_4x4())
    bar.transform(a)
    if material == "lamp":
        return [(bar, "lamp", colors.LAMP, atlas.solid(tile)(bar))]
    return [(bar, "hull", machined(colour, seed, soot=0.0), atlas.tiled(tile, period)(bar))]


def frame_of(atlas, corners, colour, seed=0, width=0.06):
    """Bars round the closed run of [corners] (x, y, z): a ring beam."""
    parts = []
    for k, a in enumerate(corners):
        parts += beam(atlas, a, corners[(k + 1) % len(corners)], width, colour, seed + k)
    return parts


def rail(atlas, points, height=0.12, colour=GREEN_PALE):
    """An open railing along [points] (x, y, z): a post at each, two rails."""
    parts = []
    for level in (height, height * 0.5):
        bar = sweep.tube([Vector(p) + Vector((0, 0, level)) for p in points],
                         [0.008] * len(points), sides=4, cap=False)
        parts.append((bar, "hull", colour, atlas.solid("plain")(bar)))
    for p in points:
        post = shapes.box((0.016, 0.016, height), bottom=False).transform(p)
        parts.append((post, "hull", colour, atlas.solid("plain")(post)))
    return parts


def around(count, radius, z=0.0, phase=0.0):
    """(x, y, azimuth) of [count] spots on a circle of [radius]."""
    return [(radius * math.cos(a), radius * math.sin(a), a)
            for a in (phase + 2 * math.pi * k / count for k in range(count))]


def lamp(atlas, tile, radius=0.03):
    """A lit dot, at the origin."""
    return [(shapes.octahedron(radius), *light(atlas, tile))]


def disc(atlas, radius, tile, height=0.012, sides=16, top=None):
    """A flat disc of light on z = 0, [top] smaller on its upper face."""
    flat = shapes.cylinder(radius, height, sides=sides, top_radius=top, smooth=False)
    return [(flat, *light(atlas, tile))]


def hatch(atlas, radius, colour=GREEN_PALE, seed=0):
    """A round hatch lying on z = 0, opening up: a rim and its lid."""
    lid = shapes.cylinder(radius, 0.03, sides=14, top_radius=radius * 0.96, bevel=0.006, smooth=False)
    mapped = atlas.planar("hatch", (1, 0, 0), (0, 1, 0))(lid)
    return [(lid, "hull", machined(colour, seed, soot=0.0), mapped)]


def lying(geometry, along="x"):
    """A shape standing on z = 0, laid down along x (or y), its middle at the origin."""
    low, high = geometry.bounds()
    geometry.transform((0, 0, -(low.z + high.z) / 2))
    return geometry.transform(rotation=(0, math.pi / 2, 0) if along == "x" else (math.pi / 2, 0, 0))


def ring_tube(radius, thickness, sides=8, points=36, tilt=(0, 0, 0)):
    """A torus of [radius] around the origin in the plane z = 0, then tilted."""
    path = [(radius * math.cos(a), radius * math.sin(a), 0)
            for a in (2 * math.pi * k / points for k in range(points + 1))]
    ring = sweep.tube(path[:-1] + [path[0]], [thickness] * points + [thickness], sides=sides, cap=False)
    return ring.transform(rotation=tilt)


def swell(geometry, seed, amount=0.03, longest=0.1):
    """[geometry] cut fine and swollen by smooth noise: a living outline."""
    geometry.subdivide(longest)
    geometry.displace(lambda p: noise.vector(p * 3.0, seed) * amount
                      + noise.vector(p * 8.0, seed + 5) * amount * 0.3)
    return geometry


def paint_basalt(seed, base=BASALT, top=BASALT_LIGHT, warm=0.0):
    """Black rock, its tops paler, its foot soot-dark, a fire's reddening [warm]."""
    def paint(p, normal):
        t = max(0.0, min(1.0, p.z / 1.0))
        colour = tuple(b + (c - b) * (0.3 + 0.7 * max(normal.z, 0.0) * t) for b, c in zip(base, top))
        colour = scale(colour, 1 + 0.25 * noise.fbm(p * 4, seed, octaves=2))
        glow = max(0.0, noise.cracks(p, seed + 3, 2.2, 0.16)) * warm
        return (colour[0] + 0.25 * glow, colour[1] + 0.05 * glow, colour[2])
    return paint
