import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:flutter_test/flutter_test.dart';

const _farm = GuideTarget.building(BuildingType.algaeFarm);

GuideAdvice _advice({String text = 'Construis', GuideTarget target = _farm}) =>
    GuideAdvice(text, target);

void main() {
  group('GuideAdvice', () {
    test('equal when its text and target are', () {
      expect(_advice(), _advice());
      expect(_advice().hashCode, _advice().hashCode);
    });

    test('different as soon as the text or the target differs', () {
      expect(_advice(), isNot(_advice(text: 'Termine le tour')));
      expect(_advice(), isNot(_advice(target: const GuideTarget.endTurn())));
      expect(_advice(), isNot('Construis'));
    });

    test('reads as its text and target', () {
      expect(
        _advice().toString(),
        'GuideAdvice(Construis, GuideTarget(base, algaeFarm))',
      );
    });
  });
}
