extends TestCase
## test/domain/fight/assault/assault_chance_test.dart: how likely an assault
## is to capture its target.

const HIGH := AssaultRating.Value.HIGH
const RISKY := AssaultRating.Value.RISKY
const LOW := AssaultRating.Value.LOW


func _chance(wins: int, rehearsals := 20) -> AssaultChance:
	return AssaultChance.new(wins, rehearsals)


func test_rates_90_percent_and_more_as_high() -> void:
	assert_eq(_chance(20).rating(), HIGH)
	assert_eq(_chance(18).rating(), HIGH)


func test_rates_50_percent_to_90_percent_as_risky() -> void:
	assert_eq(_chance(17).rating(), RISKY)
	assert_eq(_chance(10).rating(), RISKY)


func test_rates_under_50_percent_as_low() -> void:
	assert_eq(_chance(9).rating(), LOW)


func test_none_is_never_rehearsed_rated_low() -> void:
	var chance := AssaultChance.none()

	assert_eq(chance.wins, 0)
	assert_eq(chance.rehearsals, 0)
	assert_eq(chance.rate(), 0.0)
	assert_eq(chance.rating(), LOW)


func test_rate_is_the_share_of_rehearsals_won() -> void:
	assert_eq(_chance(19).rate(), 0.95)


func test_equal_when_the_counts_are() -> void:
	assert_true(_chance(3).equals(_chance(3)))
	assert_eq(_chance(3).hash_code(), _chance(3).hash_code())
	assert_false(_chance(3).equals(_chance(4)))
	assert_false(_chance(3).equals(_chance(3, 8)))


func test_reads_as_wins_over_rehearsals() -> void:
	assert_eq(str(_chance(19)), "AssaultChance(19/20)")


## Not in the Dart file: the shares the ratings start from, and the names
## of the ratings in the Dart order.
func test_holds_the_thresholds_and_the_ratings_of_dart() -> void:
	assert_eq([AssaultChance.HIGH, AssaultChance.RISKY], [0.9, 0.5])
	assert_eq(DartEnum.names(AssaultRating.Value), PackedStringArray(["high", "risky", "low"]))
	assert_false(_chance(3).equals(null))
