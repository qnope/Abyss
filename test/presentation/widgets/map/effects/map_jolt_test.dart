import 'package:abyss/presentation/widgets/map/effects/map_jolt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const length = Duration(milliseconds: 250);

  Offset joltAt(int? ms) => mapJolt(
      ms == null ? null : Duration(milliseconds: ms),
      length: length,
      amplitude: 3);

  test('shakes the map side to side just after the blow', () {
    final jolt = joltAt(40);
    expect(jolt.dx, isNot(0));
    expect(jolt.dx.abs(), lessThanOrEqualTo(3));
    expect(jolt.dy, 0);
  });

  test('stays still before the blow and once it is over', () {
    expect(joltAt(null), Offset.zero);
    expect(joltAt(-10), Offset.zero);
    expect(joltAt(250), Offset.zero);
  });
}
