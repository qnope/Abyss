"""The parts every diver has, dressed on the shared skeleton in the look the
unit picks: legs, arms, a pelvis and a barrel chest, a helmet with a lit
visor. A unit adds what makes it itself on top (props, armour, a pack)."""

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES


def legs(dress, b, look, radius=0.05):
    """Thighs and shins as tubes with a ball at each knee."""
    for letter, side in SIDES.items():
        hip, knee, ankle = b.hip_joint(side), b.knee(side), b.ankle(side)
        dress.add(forms.limb(hip, knee, radius * 1.15, radius), look, "Thigh" + letter)
        dress.add(forms.ball(knee, radius * 1.1), look, "Thigh" + letter)
        dress.add(forms.limb(knee, ankle, radius, radius * 0.85), look, "Shin" + letter)


def arms(dress, b, look, glove, radius=0.045):
    """Upper arms and forearms as tubes, a ball at each elbow, a glove at each
    wrist (in the look [glove])."""
    for letter, side in SIDES.items():
        shoulder, elbow, wrist = b.shoulder_joint(side), b.elbow(side), b.wrist(side)
        dress.add(forms.limb(shoulder, elbow, radius * 1.15, radius), look, "UpperArm" + letter)
        dress.add(forms.ball(elbow, radius * 1.1), look, "UpperArm" + letter)
        dress.add(forms.limb(elbow, wrist, radius, radius * 0.9), look, "Forearm" + letter)
        dress.add(forms.ball(wrist, radius * 1.45), glove, "Forearm" + letter)


def trunk(dress, b, look, belt, chest=0.15, waist=0.12, depth=0.8):
    """A pelvis, a barrel chest wider at the shoulders and a belt."""
    dress.add(forms.ball((0, 0, b.leg + 0.02), b.hip * 1.7, (1, depth, 0.8)), look, "Hips")
    dress.add(forms.torso(waist, chest, b.torso - 0.02, b.leg + 0.02, depth), look, "Chest")
    dress.add(forms.torso(waist * 1.1, waist * 1.1, 0.04, b.leg + 0.03, depth), belt, "Hips")


def helmet(dress, b, shell, visor, size=(1.0, 1.0, 0.95), visor_scale=(0.62, 0.34, 0.42),
           visor_lift=0.0):
    """A round helmet of [shell] with its visor, an oval of light on the
    front ([visor] is a Look mapped over the whole oval, see looks.decal)."""
    centre = b.head_centre()
    dress.add(forms.ball(centre, b.head, size, subdivisions=2), shell, "Head")
    front = (centre[0], centre[1] + b.head * 0.8, centre[2] + visor_lift)
    dress.add(forms.ball(front, b.head, visor_scale, subdivisions=2), visor, "Head")
