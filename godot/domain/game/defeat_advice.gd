class_name DefeatAdvice
extends RefCounted
## lib/domain/game/defeat_analysis.dart, `DefeatAdvice`: what the defeat
## screen tells the player to do differently.
##
## RAISE_AN_ARMY: no unit stood on the base for any of the lost raids.
## MORE_DEFENDERS: too few units; DefeatAnalysis.harpoonists_needed would
## have held. COUNTER_THE_FAMILIES: as many units as it took, but not the
## ones the waves fear.

enum Value { RAISE_AN_ARMY, MORE_DEFENDERS, COUNTER_THE_FAMILIES }
