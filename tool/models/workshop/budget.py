"""The budget of a model, declared by its script and enforced by the build."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Budget:
    """The most a model may cost: triangles drawn, materials, and the side of
    its largest texture in pixels (0: no texture at all)."""

    triangles: int
    materials: int
    texture_px: int = 0

    def overruns(self, report):
        """What the model of [report] spends over this budget, one line each."""
        found = []
        if report.triangles > self.triangles:
            found.append(f"{report.triangles} triangles, over the budget of {self.triangles}")
        if len(report.materials) > self.materials:
            found.append(f"{len(report.materials)} materials, over the budget of {self.materials}")
        for width, height in report.images:
            if max(width, height) > self.texture_px:
                found.append(f"a {width} x {height} texture, over the budget of {self.texture_px} px")
        return found

    def describe(self, report):
        """How much of this budget the model of [report] uses."""
        largest = max((max(size) for size in report.images), default=0)
        textures = (f"textures up to {largest} / {self.texture_px} px"
                    if report.images else "no texture")
        return (f"{report.triangles} / {self.triangles} triangles, "
                f"{len(report.materials)} / {self.materials} materials, {textures}")
