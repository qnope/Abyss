"""Where the pressure capsule's parts stand: a round plinth, the sphere held
a little above it by four legs, and what is fixed to the sphere. The pad's
top at z = 0, Z up, azimuths in radians from +x."""

import math

PLINTH = (0.98, 0.14)  # radius, height
RADIUS = 0.6  # of the sphere
CENTRE = 1.02  # its height
FRONT = -math.pi / 4  # the azimuth facing the game's camera and the headquarters
LEGS = tuple(k * math.pi / 2 for k in range(4))  # the legs and the gyro rings' pivot posts


def on_sphere(azimuth, latitude, radius=RADIUS):
    """The point at [azimuth] and [latitude] (radians, 0 on the equator) on a
    sphere concentric with the capsule's, of [radius]."""
    return (radius * math.cos(latitude) * math.cos(azimuth),
            radius * math.cos(latitude) * math.sin(azimuth),
            CENTRE + radius * math.sin(latitude))
