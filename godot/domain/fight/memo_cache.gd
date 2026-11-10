class_name MemoCache
extends RefCounted
## lib/domain/fight/memo_cache.dart: remembers the last `capacity` answers of
## a costly pure computation, forgetting the least recently used first. Lets
## a screen ask the same question at every rebuild, or go back and forth
## between a few inputs, without paying for it again.
##
## `MemoCache<K, V>` in Dart: the keys and the answers are Variants here. A
## Dictionary iterates in insertion order as a LinkedHashMap does, and a key
## erased then set again goes last.

var capacity: int

var _answers := {}


## Dart asserts a capacity above 0, in debug only: this logs an error and
## goes on as Dart does without the assertion, remembering nothing.
func _init(capacity_ := 32) -> void:
	capacity = capacity_
	if capacity <= 0:
		push_error("MemoCache: a capacity of %d remembers nothing" % capacity)


## Number of answers remembered.
func length() -> int:
	return _answers.size()


## `get(key, compute)`, a name Object owns: the answer for `key`, computed
## by `compute` when not remembered.
func answer(key: Variant, compute: Callable) -> Variant:
	if _answers.has(key):
		var remembered: Variant = _answers[key]
		_answers.erase(key)
		_answers[key] = remembered
		return remembered
	var computed: Variant = compute.call()
	_answers[key] = computed
	if _answers.size() > capacity:
		for first: Variant in _answers:
			_answers.erase(first)
			break
	return computed
