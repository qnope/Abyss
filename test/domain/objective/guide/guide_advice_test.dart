import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:flutter_test/flutter_test.dart';

const _farm = GuideTarget.building(BuildingType.algaeFarm);
const _lesson = GuideLesson(ObjectiveId.algaeFarm);

GuideAdvice _advice({
  GuideMessage message = _lesson,
  GuideTarget target = _farm,
}) => GuideAdvice(message, target);

void main() {
  group('GuideAdvice', () {
    test('equal when its message and target are', () {
      expect(_advice(), _advice());
      expect(_advice().hashCode, _advice().hashCode);
    });

    test('different as soon as the message or the target differs', () {
      expect(_advice(), isNot(_advice(message: const GuideGoalMet())));
      expect(_advice(), isNot(_advice(target: const GuideTarget.endTurn())));
      expect(_advice(), isNot(_lesson));
    });

    test('reads as its message and target', () {
      expect(
        _advice().toString(),
        'GuideAdvice(GuideLesson[ObjectiveId.algaeFarm], '
        'GuideTarget(base, algaeFarm))',
      );
    });
  });

  group('GuideMessage', () {
    test('equal when of the same kind with the same figures', () {
      expect(const GuideStorm(8), const GuideStorm(8));
      expect(const GuideStorm(8).hashCode, const GuideStorm(8).hashCode);
      expect(const GuideGoalMet(), const GuideGoalMet());
      expect(
        const GuideRaidAlert(12, 28, needed: 5, missing: 2),
        const GuideRaidAlert(12, 28, needed: 5, missing: 2),
      );
    });

    test('different as soon as the kind or a figure differs', () {
      expect(const GuideStorm(8), isNot(const GuideStorm(9)));
      expect(const GuideGoalMet(), isNot(const GuideExploring()));
      expect(
        const GuideWreck(9, hasBarracks: false),
        isNot(const GuideWreck(9, hasBarracks: true)),
      );
      expect(
        const GuideRaidAlert(12, 28),
        isNot(const GuideRaidAlert(12, 28, needed: 5)),
      );
      expect(
        const GuideLesson(ObjectiveId.mines),
        isNot(const GuideLesson(ObjectiveId.explore)),
      );
    });
  });
}
