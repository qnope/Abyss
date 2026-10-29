import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/widgets/base/base_slot.dart';

void main() {
  const slot = BaseSlot(u: 6.4, v: 6.4, footprint: 3, scale: 1.05);

  test('slots with the same place are equal', () {
    const same = BaseSlot(u: 6.4, v: 6.4, footprint: 3, scale: 1.05);
    expect(slot, same);
    expect(slot.hashCode, same.hashCode);
    expect(slot, isNot(const BaseSlot(u: 6.4, v: 6.4, footprint: 2, scale: 1.05)));
    expect(slot, isNot(const BaseSlot(u: 6.4, v: 6.4, footprint: 3, scale: 1.0)));
  });

  test('the footprint is a square of its size around its centre', () {
    expect(slot.bounds.left, closeTo(4.9, 1e-9));
    expect(slot.bounds.top, closeTo(4.9, 1e-9));
    expect(slot.bounds.width, 3);
    expect(slot.bounds.height, 3);
  });

  test('a ground point lies inside the footprint or not', () {
    expect(slot.contains(const Offset(6.4, 6.4)), isTrue);
    expect(slot.contains(const Offset(5.0, 7.8)), isTrue);
    expect(slot.contains(const Offset(4.8, 6.4)), isFalse);
    expect(slot.contains(const Offset(6.4, 8.0)), isFalse);
  });

  test('the depth sorts a slot from the back to the front', () {
    expect(slot.depth, closeTo(6.4 + 6.4 + 1.5, 1e-9));
  });
}
