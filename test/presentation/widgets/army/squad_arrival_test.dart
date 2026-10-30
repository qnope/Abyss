import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scout = UnitType.scout, guardian = UnitType.guardian;

  group('SquadArrival.of', () {
    test('nothing arrives when the count stays or goes down', () {
      expect(SquadArrival.of(4, 4), isNull);
      expect(SquadArrival.of(4, 2), isNull);
      expect(SquadArrival.of(0, 0), isNull);
    });

    test('a new figure is the recruit, landing on its slot', () {
      expect(SquadArrival.of(3, 8),
          const SquadArrival(figure: 2, stays: true, gained: 5));
      expect(SquadArrival.of(0, 1),
          const SquadArrival(figure: 0, stays: true, gained: 1));
    });

    test('without a new figure, the recruit lands on the next free slot '
        'and joins the ranks', () {
      expect(SquadArrival.of(2, 4),
          const SquadArrival(figure: 2, stays: false, gained: 2));
    });

    test('a full squad takes the recruit on its front slot', () {
      expect(SquadArrival.of(70, 75),
          const SquadArrival(figure: 0, stays: true, gained: 5));
    });

    test('between two rosters, only the squads that grew', () {
      expect(
        SquadArrival.between(
          {scout: 3, guardian: 10},
          {scout: 8, guardian: 9, UnitType.saboteur: 0},
        ),
        {scout: const SquadArrival(figure: 2, stays: true, gained: 5)},
      );
    });

    test('two arrivals alike are one, and read as such', () {
      final arrival = SquadArrival.of(3, 8)!;
      expect(arrival.hashCode, SquadArrival.of(4, 9)!.hashCode);
      expect({arrival, SquadArrival.of(4, 9)}, hasLength(1));
      expect(arrival, isNot(SquadArrival.of(3, 9)));
      expect('$arrival', 'SquadArrival(2, stays: true, +5)');
    });
  });

  group('SquadArrival timeline', () {
    test('lasts less than a second', () {
      expect(AbyssMotion.recruitArrival, lessThan(const Duration(seconds: 1)));
    });

    test('falls from above, then lands before the ring spreads', () {
      expect(SquadArrival.fallAt(0), 1);
      expect(SquadArrival.fallAt(.2), inExclusiveRange(0, 1));
      expect(SquadArrival.fallAt(SquadArrival.landing), 0);
      expect(SquadArrival.ringAt(.2), 0);
      expect(SquadArrival.ringAt(.6), inExclusiveRange(0, 1));
      expect(SquadArrival.ringAt(1), 1);
    });

    test('the plaque pops and the gain floats after the landing', () {
      expect(SquadArrival.popAt(.2), 0);
      expect(SquadArrival.popAt(.7), inExclusiveRange(0, 1));
      expect(SquadArrival.popAt(1), 1);
      expect(SquadArrival.floatAt(.1), 0);
      expect(SquadArrival.floatAt(.7), inExclusiveRange(0, 1));
    });

    test('a recruit joining the ranks fades once landed', () {
      expect(SquadArrival.fadeAt(.3), 1);
      expect(SquadArrival.fadeAt(.75), inExclusiveRange(0, 1));
      expect(SquadArrival.fadeAt(1), 0);
    });
  });
}
