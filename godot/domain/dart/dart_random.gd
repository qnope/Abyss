class_name DartRandom
extends RefCounted
## The Dart VM's `Random(seed)`, bit for bit: every die of the game comes
## from one, so the port draws what the Dart rules drew. Written from the
## SDK's `math_patch.dart` as test/tool/vectors/spec/dart_random_spec.dart
## and held against reference/vectors/dart_random.json.
##
## One 64-bit state, advanced by a multiply-with-carry in base 2^32. GDScript
## ints wrap as Dart's; `>>` keeps the sign, hence the mask after each shift.
##
## It remembers its seed, as `SeededRandom` of lib/domain/replay does for the
## journal: a ported rule takes a DartRandom where Dart takes a `Random`.

## What next_int() answers to a bound Dart would have thrown a RangeError
## for: no draw is ever negative.
const REFUSED := -1

const _MASK32 := 0xFFFFFFFF
const _POW32 := 4294967296
const _MULTIPLIER := 0xffffda61

## The seed it was built from.
var initial_seed: int:
	get:
		return _seed

var _seed: int
var _state: int


func _init(seed_value: int) -> void:
	_seed = seed_value
	_state = _mixed(seed_value)
	for _round: int in 4:
		_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)


## A whole number from 0 to bound - 1, for a bound from 1 to 2^32. Dart
## throws for any other bound; GDScript has no exceptions, so this logs an
## error, draws nothing and returns REFUSED.
func next_int(bound: int) -> int:
	if bound <= 0 or bound > _POW32:
		push_error("DartRandom.next_int(%d): the bound must be from 1 to 2^32" % bound)
		return REFUSED
	_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)
	var low := _state & _MASK32
	if bound & -bound == bound:
		return low & (bound - 1)
	var result := low % bound
	while low - result + bound > _POW32:
		_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)
		low = _state & _MASK32
		result = low % bound
	return result


## A float from 0 inclusive to 1 exclusive: 26 bits then 27, of two draws.
func next_double() -> float:
	_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)
	var high := _state & 0x3FFFFFF
	_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)
	return (high * 134217728.0 + (_state & 0x7FFFFFF)) / 9007199254740992.0


func next_bool() -> bool:
	_state = _MULTIPLIER * (_state & _MASK32) + ((_state >> 32) & _MASK32)
	return _state & 1 == 0


## Dart's `list.shuffle(random)`: from the end, each element is swapped with
## one drawn among those before it and itself. Never Array.shuffle(), which
## draws from Godot's own generator.
static func shuffle(list: Array, random: DartRandom) -> void:
	var length := list.size()
	while length > 1:
		var position := random.next_int(length)
		length -= 1
		var moved: Variant = list[length]
		list[length] = list[position]
		list[position] = moved


## Thomas Wang's 64-bit mix of the seed; 0 is replaced by 0x5a17.
static func _mixed(seed_value: int) -> int:
	var n := seed_value
	n = ~n + (n << 21)
	n = n ^ ((n >> 24) & 0xFFFFFFFFFF)
	n = n * 265
	n = n ^ ((n >> 14) & 0x3FFFFFFFFFFFF)
	n = n * 21
	n = n ^ ((n >> 28) & 0xFFFFFFFFF)
	n = n + (n << 31)
	return n if n != 0 else 0x5a17
