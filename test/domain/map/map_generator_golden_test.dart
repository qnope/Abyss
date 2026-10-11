import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/map_generator.dart';
import '../../helpers/map_fingerprint.dart';

/// Fingerprints of the maps a single player gets, captured before maps
/// learned to hold several bases: a lone player's map must never change. Level 3 was recaptured when the
/// volcano grew to a 2x2 footprint.
const _golden = <int, List<int>>{
  1: [1571951233, 2055003048, 2750926549, 12, 10],
  42: [396363621, 1190823070, 1014633587, 10, 11],
  123: [3572676688, 3728283768, 33725388, 9, 8],
  777: [3614134476, 1368645896, 1963665531, 11, 8],
  2024: [198791399, 3666432626, 2268720082, 10, 11],
  99999: [127208571, 1042239294, 3202106484, 8, 11],
  31337: [1263256019, 1156572413, 3428174847, 10, 10],
  2147483632: [1792596019, 1782540289, 3086644629, 10, 10],
};

void main() {
  group('MapGenerator single player golden maps', () {
    for (final entry in _golden.entries) {
      test('seed ${entry.key} gives the same three levels', () {
        final l1 = MapGenerator.generate(seed: entry.key);
        final l2 = MapGenerator.generate(
          seed: entry.key + 1,
          level: 2,
          reservedPassages: passagesOf(l1.map),
        );
        final l3 = MapGenerator.generate(
          seed: entry.key + 2,
          level: 3,
          reservedPassages: passagesOf(l2.map),
        );
        expect([
          mapFingerprint(l1.map),
          mapFingerprint(l2.map),
          mapFingerprint(l3.map),
        ], entry.value.sublist(0, 3));
        expect([l1.baseX, l1.baseY], entry.value.sublist(3));
      });
    }
  });
}
