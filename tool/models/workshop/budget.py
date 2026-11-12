"""The budget of a model, declared by its script and enforced by the build."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Budget:
    """The most a model may cost: triangles drawn, materials, and the side of
    its largest texture in pixels (0: no texture at all), the bones of its
    skeleton and the keyframes of its animations (0: none)."""

    triangles: int
    materials: int
    texture_px: int = 0
    bones: int = 0
    keyframes: int = 0

    def within(self, caps):
        """What this budget declares over the caps [caps] of its family (a
        Budget too), one line each."""
        found = []
        for field in ("triangles", "materials", "texture_px", "bones", "keyframes"):
            if getattr(self, field) > getattr(caps, field):
                found.append(f"{field} {getattr(self, field)}, "
                             f"over the family's {getattr(caps, field)}")
        return found

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
        if report.bones > self.bones:
            found.append(f"{report.bones} bones, over the budget of {self.bones}")
        if report.keyframes > self.keyframes:
            found.append(f"{report.keyframes} keyframes, over the budget of {self.keyframes}")
        return found

    def describe(self, report):
        """How much of this budget the model of [report] uses."""
        largest = max((max(size) for size in report.images), default=0)
        textures = (f"textures up to {largest} / {self.texture_px} px"
                    if report.images else "no texture")
        text = (f"{report.triangles} / {self.triangles} triangles, "
                f"{len(report.materials)} / {self.materials} materials, {textures}")
        if self.bones or report.bones:
            text += (f", {report.bones} / {self.bones} bones, "
                     f"{report.keyframes} / {self.keyframes} keyframes")
        return text
