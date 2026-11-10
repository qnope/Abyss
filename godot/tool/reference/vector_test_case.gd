class_name VectorTestCase
extends TestCase
## The base of a test driven by the vectors of reference/vectors: the port
## must answer as the Dart rules did, to the last bit.


## Exact equality as assert_eq, and a float by its bits: a NaN equals a NaN,
## 0.0 is not -0.0. A failure shows the floats as the vectors write them.
func assert_same(actual: Variant, expected: Variant, message := "") -> void:
	assert_eq(VectorValues.encode(actual), VectorValues.encode(expected), message)
