import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_collect_messages.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';

void main() {
  test('each kind of loot has its own title', () {
    expect(titleFor(en, CellContentType.resourceBonus),
        en.screenTreasureCollected);
    expect(titleFor(en, CellContentType.ruins), en.screenRuinsSearched);
    expect(titleFor(en, CellContentType.wreck), en.screenWreckSearched);
  });

  test('a collect elsewhere gets the plain collect title', () {
    expect(titleFor(en, CellContentType.empty), en.screenCollectTitle);
    expect(en.screenCollectTitle, isNot(en.screenTreasureCollected));
  });
}
