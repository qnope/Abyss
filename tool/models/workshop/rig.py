"""What a script declares of a skeleton, without Blender: bones with their
parents, and the actions (idle, swim, attack, hit...) that move them. The
build turns it into an armature (armature.py) and the glb into glTF
animations. Rotations are in degrees about the model's own axes (Blender's,
Z up) at rest, applied on top of the parent's: a tail bone bends from the
bone before it."""

from dataclasses import dataclass, field

from workshop.skin import centre


@dataclass(frozen=True)
class Bone:
    """A bone from [head] to [tail] in model space, under [parent] (None for a
    root)."""

    name: str
    parent: str | None
    head: tuple
    tail: tuple


@dataclass(frozen=True)
class Key:
    """A pose at [frame]: [rotation] in degrees (x, y, z) and [location] as an
    offset of the rest position, both in model axes."""

    frame: int
    rotation: tuple = (0.0, 0.0, 0.0)
    location: tuple = (0.0, 0.0, 0.0)


@dataclass(frozen=True)
class Action:
    """[tracks] gives each moving bone its keys, by frame. A [loop] ends where
    it starts (the game plays it again at once): its keys must close on
    themselves. [frames] is its length, played at [Rig.fps]."""

    name: str
    frames: int
    loop: bool
    tracks: dict

    @property
    def keyframes(self):
        return sum(len(keys) for keys in self.tracks.values())


@dataclass
class Rig:
    """The skeleton of a model and its actions."""

    fps: int = 24
    bones: list = field(default_factory=list)
    actions: list = field(default_factory=list)

    def bone(self, name, parent, head, tail):
        """Adds the bone [name]; its [parent] is declared before it."""
        if name in self.names:
            raise ValueError(f"bone {name} twice")
        if parent is not None and parent not in self.names:
            raise ValueError(f"bone {name}: parent {parent} is not declared yet")
        self.bones.append(Bone(name, parent, tuple(head), tuple(tail)))
        return name

    def chain(self, prefix, parent, points):
        """Bones <prefix>1.. from point to point, each under the one before
        (the first under [parent]); gives their names."""
        names = []
        for i, (head, tail) in enumerate(zip(points, points[1:]), 1):
            names.append(self.bone(f"{prefix}{i}", names[-1] if names else parent, head, tail))
        return names

    def action(self, name, frames, tracks, loop=False):
        """Adds the action [name] of [frames] frames; [tracks] gives bone names
        lists of Keys, which must rise in frame within [0, frames]."""
        if name in [action.name for action in self.actions]:
            raise ValueError(f"action {name} twice")
        for bone, keys in tracks.items():
            if bone not in self.names:
                raise ValueError(f"action {name}: no bone {bone}")
            rising = [key.frame for key in keys]
            if rising != sorted(set(rising)) or rising[0] < 0 or rising[-1] > frames:
                raise ValueError(f"action {name}, {bone}: keys out of order or range")
            if loop and (keys[0].rotation, keys[0].location) != (keys[-1].rotation,
                                                                  keys[-1].location):
                raise ValueError(f"action {name}, {bone}: a loop must end where it starts")
        self.actions.append(Action(name, frames, loop, tracks))

    @property
    def names(self):
        return [bone.name for bone in self.bones]

    def centres(self, names):
        """The middle of each of the bones [names], from head to tail."""
        by_name = {bone.name: bone for bone in self.bones}
        return [centre(by_name[name].head, by_name[name].tail) for name in names]

    @property
    def keyframes(self):
        return sum(action.keyframes for action in self.actions)
