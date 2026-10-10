import 'package:abyss/presentation/widgets/map/map_level_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';

void main() {
  test('lists the three depths from the surface down', () {
    expect(MapLevelInfo.levels, [1, 2, 3]);
  });

  test('names each depth', () {
    expect(MapLevelInfo.nameOf(fr, 1), 'Surface');
    expect(MapLevelInfo.nameOf(fr, 2), 'Profondeurs');
    expect(MapLevelInfo.nameOf(fr, 3), 'Noyau');
  });

  test('names each depth in English and Spanish', () {
    expect(MapLevelInfo.nameOf(en, 2), 'Depths');
    expect(MapLevelInfo.nameOf(en, 3), 'Core');
    expect(MapLevelInfo.nameOf(es, 1), 'Superficie');
    expect(MapLevelInfo.nameOf(es, 2), 'Profundidades');
  });

  test('pictures each depth on a save card', () {
    const dir = 'assets/illustrations/saves';
    expect(MapLevelInfo.saveThumbnailOf(1), '$dir/depth_surface.svg');
    expect(MapLevelInfo.saveThumbnailOf(2), '$dir/depth_deep.svg');
    expect(MapLevelInfo.saveThumbnailOf(3), '$dir/depth_core.svg');
  });
}
