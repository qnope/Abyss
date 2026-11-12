"""One tile of the sea floor under construction: the ground, whose heights
and colours a recipe shapes with mounds and stains, and the props it puts
on it. Every tile of a level has the same border (the height of the edge,
the colour of the sand, nothing standing on it) and differs inside, so that
any two meet without a seam, in any quarter turn."""

import math
import random
from dataclasses import dataclass, field

from catalog.seabed import field as fields
from catalog.seabed.ground import EDGE_DROP, FOOT, atlas_top, heightfield, skirt
from workshop.colors import mix, scale

MARGIN = 0.14  # from the border, where a variant's own shape fades out
REACH = 0.495  # how far from the centre a prop may reach: inside the cell
NEAR = 0.025  # from the border, where the grid's groove darkens the colour


@dataclass
class Tile:
    """[top] is the height of the tile's top: 0 lit, lower under the fog.
    [texture] names its tile in the model's atlas."""

    model: object
    level: object
    path: str
    location: tuple
    seed: int
    top: float
    texture: str
    mounds: list = field(default_factory=list)
    stains: list = field(default_factory=list)

    def __post_init__(self):
        self.rng = random.Random(self.seed)
        self.piece = self.model.piece(self.path, self.location)

    def mound(self, x, y, radius, height):
        """A swell (or a hollow, with a negative [height]) of the ground."""
        self.mounds.append(((x, y), radius, height))

    def stain(self, x, y, radius, colour):
        """A patch of another colour on the ground."""
        self.stains.append(((x, y), radius, colour))

    def height(self, x, y):
        """The ground's height at (x, y): the border held at the edge, the
        shared ripples and the variant's mounds inside."""
        i, j, amplitude = self.level.ripple
        ripple = amplitude * math.sin(2 * math.pi * (i * x + j * y)
                                      + 1.2 * fields.wave(x, y, self.level.seed + 5, 2))
        swell = sum(h * fields.blob(x, y, c, r) for c, r, h in self.mounds)
        inside = fields.envelope(x, y, MARGIN)
        edge = self.top + EDGE_DROP
        return edge + inside * (self.top - edge + ripple + 0.02 * fields.wave(x, y, self.level.seed)
                                + swell)

    def _paint(self, base, patch):
        seed = self.level.seed

        def paint(p, normal):
            # Uniform on the border, so that a tile can be turned a quarter.
            inside = fields.envelope(p.x, p.y, MARGIN)
            colour = scale(base, 1 + inside * 0.16 * fields.wave(p.x, p.y, seed + 1))
            colour = mix(base, mix(colour, patch, 0.5 + 0.5 * fields.wave(p.x, p.y, seed + 2) - 0.3),
                         inside)
            for (cx, cy), radius, stain in self.stains:
                colour = mix(colour, stain, fields.blob(p.x, p.y, (cx, cy), radius) * inside)
            near = min(fields.EDGE - abs(p.x), fields.EDGE - abs(p.y))
            return scale(colour, 1 - 0.2 * (1 - fields.smooth(near / NEAR)))
        return paint

    def lay(self):
        """The ground in the level's sand (or its dim sand under the fog),
        with its patch showing through, and the skirt of the slab."""
        level, hidden = self.level, self.top < 0
        sand, patch = (level.fog_sand, level.fog_patch) if hidden else (level.sand, level.patch)
        atlas = self.model.atlas
        self.piece.add(heightfield(self.height), "seabed", self._paint(sand, patch),
                       atlas_top(atlas, self.texture))
        self.piece.add(skirt(self.top + EDGE_DROP, FOOT), "seabed", level.wall, atlas.blank)

    def put(self, parts, x, y, turn=0.0, size=1.0, sink=0.01):
        """The [parts] (geometry, material, paint), their foot on the ground
        at (x, y), turned by [turn] and scaled by [size]; slid inward if they
        would overhang the tile, so that a neighbour's border props never meet."""
        for geometry, _, _ in parts:
            geometry.transform((0, 0, 0), (0, 0, turn), size)
        xs = [v.x for geometry, _, _ in parts for v in geometry.verts]
        ys = [v.y for geometry, _, _ in parts for v in geometry.verts]
        x = min(max(x, -REACH - min(xs)), REACH - max(xs))
        y = min(max(y, -REACH - min(ys)), REACH - max(ys))
        for geometry, material, paint in parts:
            geometry.transform((x, y, self.height(x, y) - sink))
            self.piece.add(geometry, material, paint)
