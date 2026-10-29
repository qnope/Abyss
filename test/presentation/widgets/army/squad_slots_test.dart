import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/squad_size.dart';
import 'package:abyss/presentation/widgets/army/squad_slots.dart';
import 'package:flutter_test/flutter_test.dart';

double _depth(Offset slot) => slot.dx + slot.dy;

void main() {
  group('SquadSlots', () {
    test('has one slot per figure of the largest squad', () {
      expect(SquadSlots.arrival, hasLength(SquadSize.max));
      expect(SquadSlots.arrival.toSet(), hasLength(SquadSize.max));
    });

    test('the first arrival stands in front of the centre', () {
      expect(SquadSlots.arrival.first, const Offset(.3, .3));
    });

    test('every slot lies inside the drill pad', () {
      const half = ArmyLayout.padSize / 2;
      for (final slot in SquadSlots.arrival) {
        expect(slot.dx.abs(), lessThan(half), reason: '$slot');
        expect(slot.dy.abs(), lessThan(half), reason: '$slot');
      }
    });

    test('draws the first arrivals only', () {
      for (var n = 0; n <= SquadSize.max; n++) {
        expect(
          SquadSlots.backToFront(n).toSet(),
          SquadSlots.arrival.take(n).toSet(),
          reason: '$n figures',
        );
      }
    });

    test('draws the figures from the back to the front', () {
      for (var n = 0; n <= SquadSize.max; n++) {
        final depths = SquadSlots.backToFront(n).map(_depth).toList();
        expect(depths, orderedEquals([...depths]..sort()), reason: '$n');
      }
    });

    test('keeps arrival order between figures at the same depth', () {
      expect(SquadSlots.backToFront(SquadSize.max).take(3), const [
        Offset(-.55, -.05),
        Offset(-.05, -.55),
        Offset(-1.05, .45),
      ]);
    });
  });
}
