class_name PadMarker
extends RefCounted
## The look of an empty pad, so that the player sees where to build without
## the pads outshining the deck: its slab shaded down into the deck's slate,
## its rim a faint cyan glow that breathes. Both materials are copies of the
## pad's own, shared by every empty pad: the deck, which shares the slab's
## material, keeps its look, and one change of the glow lights them all.

## The slab's colour, times its painted vertex colours.
const STONE_SHADE := Color(0.42, 0.47, 0.55)
## The rim's light, between its dimmest and brightest breath.
const GLOW_ENERGY := 0.4
const GLOW_SWING := 0.35
## The rim's colour, times its painted vertex colours: lit, it would outshine
## its glow.
const GLOW_SHADE := Color(0.3, 0.3, 0.3)
## A breath, in seconds: the pulse of a glow in the Flutter game.
const PULSE_CYCLE := 3.0

var stone: StandardMaterial3D
var glow: StandardMaterial3D


## Copies the slab's (first) and the rim's (second) materials of [param pad].
func _init(pad: Mesh) -> void:
	stone = pad.surface_get_material(0).duplicate() as StandardMaterial3D
	stone.albedo_color = STONE_SHADE
	glow = pad.surface_get_material(1).duplicate() as StandardMaterial3D
	glow.emission_energy_multiplier = GLOW_ENERGY
	glow.albedo_color = GLOW_SHADE


## Sets the rim's glow as it is [param seconds] into its breathing.
func breathe(seconds: float) -> void:
	var phase := sin(TAU * seconds / PULSE_CYCLE)
	glow.emission_energy_multiplier = GLOW_ENERGY * (1.0 + GLOW_SWING * phase)
