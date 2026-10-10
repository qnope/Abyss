import 'package:abyss/presentation/extensions/rampart_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('the Citadel rampart', () {
    test('is none without a Citadel', () {
      expect(RampartTexts.coral(fr, 0), 'aucun');
      expect(RampartTexts.coral(en, 0), 'none');
      expect(RampartTexts.coral(es, 0), 'ninguna');
    });

    test('tells its HP and DEF', () {
      expect(RampartTexts.coral(fr, 3), '120 PV, DEF 7');
      expect(RampartTexts.coral(en, 3), '120 HP, DEF 7');
      expect(RampartTexts.coral(es, 3), '120 PV, DEF 7');
    });
  });

  test('the magma rampart tells its HP, ATK and DEF', () {
    expect(RampartTexts.magma(fr, 5), '200 PV, ATK 14, DEF 8');
    expect(RampartTexts.magma(en, 5), '200 HP, ATK 14, DEF 8');
  });
}
