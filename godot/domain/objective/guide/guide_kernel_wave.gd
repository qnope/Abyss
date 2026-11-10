class_name GuideKernelWave
extends GuideMessage
## `GuideKernelWave` of lib/domain/objective/guide/guide_campaign_messages.dart:
## a wave of `monsters` krakens comes to take the kernel back: at least
## `needed` units (an int) must stand in its garrison; null when no number
## would hold.

var monsters: int
var needed: Variant


func _init(monsters_: int, needed_: Variant = null) -> void:
	monsters = monsters_
	needed = needed_


func _figures() -> PackedStringArray:
	return PackedStringArray([str(monsters), GuideMessage.or_minus_one(needed)])
