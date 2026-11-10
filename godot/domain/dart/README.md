# domain/dart

What the Dart language does and GDScript does otherwise: its random
generator, its sort, part of its arithmetic, the names of its enum values. The rules of `lib/domain` are
ported to give **the same game**, to the last die; wherever one of them
draws, shuffles, sorts with a comparator, divides or rounds, the port goes
through here. Each class is held against `reference/vectors/dart_*.json`
(`reference/vectors/README.md` has the algorithms). `DartInt` has no vector
yet: its test lists what the Dart VM answered.

## What a ported rule writes

| Dart | GDScript | Never |
| --- | --- | --- |
| `Random(seed)`, `SeededRandom(seed)`, `.seed` | `DartRandom.new(seed)`, `.initial_seed` (`seed` is a function of Godot) | `randi`, `randf`, `RandomNumberGenerator`, `pick_random` |
| `Random()` | `DartRandom.unseeded()`, seeded by Godot's generator, no `SeededRandom` | |
| `random is SeededRandom ? random.seed : random.nextInt(...)` | `random.initial_seed if random.is_seeded else random.next_int(...)` (`AnnounceAttackAction`): every `DartRandom` remembers its seed, `is_seeded` tells a `SeededRandom` | |
| `Random(seed)` that may reach such a test (the dice of a script run, `ScriptTurn(random: Random(1))`) | `DartRandom.new(seed, false)`: it draws the same, but is no `SeededRandom` | |
| `random.nextInt(n)`, `nextDouble()`, `nextBool()` | `random.next_int(n)`, `next_double()`, `next_bool()` | |
| `list.shuffle(random)` | `DartRandom.shuffle(list, random)` | `Array.shuffle` |
| `list.sort(compare)` | `DartSort.sort(list, compare)`, `compare` returning an int | `sort_custom` |
| `a.compareTo(b)` | `DartSort.compare_ints(a, b)` between ints, else `DartNum.compare_to(a, b)` | |
| `a ~/ b` | `DartMath.trunc_div(a, b)` | `/`, which reads as the next line |
| `a / b` between two ints | `DartMath.quotient(a, b)`, a float | `/`, which truncates |
| `a % b` | `DartMath.modulo(a, b)`; `%` if neither can be negative | `%` below zero, `posmod` |
| `x.round()`, `floor()`, `ceil()`, `toInt()` | `roundi(x)`, `floori(x)`, `ceili(x)`, `int(x)`; `DartMath.round(x)`... if x can leave 64 bits | |
| `pow(a, b)`, `exponentialCost` | `DartMath.int_pow(a, b)`, `DartMath.round_times_power(base, 8, 5, step)` | `pow`, `**` |
| `a >>> s`, `a.bitLength`, a shift of 64 or more | `DartBits.ushr(a, s)`, `bit_length(a)`, `shl`, `shr` | |
| `min`, `max`, `clamp` between ints | `mini`, `maxi`, `clampi` | |
| `min`, `max`, `clamp` with a float | `DartNum.min`, `max`, `clamp` if a zero's sign or a NaN matters, else `minf`, `maxf`, `clampf` | |
| `value.name`, `Enum.values.asNameMap()[name]` | `DartEnum.name_of(Enum.Value, value)`, `DartEnum.by_name(Enum.Value, name)` (null when none) | `Enum.Value.keys()`, `find_key`: GDScript's constants, not Dart's names |
| `int.tryParse(text)` | `DartInt.try_parse(text)` (null when none) | `to_int`, `is_valid_int`: they read other texts |
| `value.index`, `Enum.values[i]` | the value itself, `i as Enum.Value`: the port declares the values in the Dart order | |

`godot/domain/native_calls_test.gd` fails on the calls of the last column
that a text search can tell. `%` and `/` are for the review: a `/` in a rule
has a float on one side.

## What GDScript does as Dart

Checked against the vectors in `dart_native_test.gd` and
`dart_native_float_test.gd`, to write as it is: `+`, `-`, `*` and unary `-`
on ints (they wrap to 64 bits), `&`, `|`, `^`, `~`, `<<` and `>>` by 0 to 63,
`absi`, `mini`, `maxi`, `clampi`; float literals, `+`, `-`, `*`, `/` between
floats, `roundi`, `floori`, `ceili` and `int()` inside 64 bits. GDScript's
`%` between ints is Dart's `remainder`. And `Array.sort()` without comparator
on a list of ints, where equal elements cannot be told apart
(`dart_sort_test.gd`).

## Where Dart throws

GDScript has no exceptions. A function here that meets what makes Dart throw
(`next_int` of a bound out of 1..2^32, a division by zero, a NaN to round,
a negative shift, `clamp` with bounds out of order) logs an error with
`push_error` and returns a value Dart never returned: `DartRandom.REFUSED`
(-1) without drawing, else 0. A test fails on a logged error unless it called
`expect_error` first.

## Traps met on the way

- GDScript keeps one constant for `0.0` and `-0.0` in a function, the first
  it meets: a `-0.0` literal may be `0.0`.
- `1 / 3` is 0: a Dart constant such as `1 / 3` is `1.0 / 3.0` here.
- A literal below the smallest normal double (`5e-324`, `1e-320`) parses
  as 0.
- A 17-digit literal may parse one bit away from Dart's:
  `0.39285714285714285`, which Dart prints for `110 / 280`, reads as the
  next double up. A test writes a double Dart printed by its bits
  (`VectorValues.float_of`).
- The smallest int divided by -1, with `/` or `%`, crashes the engine.
- From 2^63 up, `int(x)` and `roundi(x)` depend on the processor, as does a
  shift of 64 or more.
