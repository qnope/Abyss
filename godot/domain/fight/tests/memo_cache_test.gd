extends TestCase
## test/domain/fight/memo_cache_test.dart: the last answers of a costly
## computation, remembered.

var _calls := 0


func _nothing() -> Variant:
	_calls += 1
	return null


func _count() -> int:
	_calls += 1
	return _calls


func test_computes_an_answer_once_null_answers_included() -> void:
	var cache := MemoCache.new()

	assert_null(cache.answer("a", _nothing))
	assert_null(cache.answer("a", _nothing))
	assert_eq(_calls, 1)


func test_forgets_the_least_recently_used_answer_beyond_its_capacity() -> void:
	var cache := MemoCache.new(2)

	cache.answer("a", _count)
	cache.answer("b", _count)
	cache.answer("a", _count)
	cache.answer("c", _count)

	assert_eq(cache.length(), 2)
	assert_eq(cache.answer("a", _count), 1)
	assert_eq(cache.answer("b", _count), 4)


## Not in the Dart file: the capacity it is built with, 32 by default.
func test_holds_its_capacity() -> void:
	assert_eq(MemoCache.new().capacity, 32)
	assert_eq(MemoCache.new(2).capacity, 2)


## Not in the Dart file: Dart asserts a capacity above 0, in debug only;
## without the assertion such a cache remembers nothing.
func test_refuses_a_capacity_of_zero() -> void:
	expect_error("capacity")
	var cache := MemoCache.new(0)
	assert_eq(cache.answer("a", _count), 1)
	assert_eq(cache.answer("a", _count), 2)
	assert_eq(cache.length(), 0)
