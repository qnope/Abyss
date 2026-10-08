import 'package:abyss/domain/worksite/worksite.dart';
import 'package:abyss/domain/worksite/worksite_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorksiteRules', () {
    test('one site, then one more at HQ 5 and at HQ 10', () {
      expect(WorksiteRules.buildSites(0), 1);
      expect(WorksiteRules.buildSites(4), 1);
      expect(WorksiteRules.buildSites(5), 2);
      expect(WorksiteRules.buildSites(9), 2);
      expect(WorksiteRules.buildSites(10), 3);
    });

    test('names the HQ level that opens the next site', () {
      expect(WorksiteRules.nextSiteAtHq(1), 5);
      expect(WorksiteRules.nextSiteAtHq(5), 10);
      expect(WorksiteRules.nextSiteAtHq(10), isNull);
    });
  });

  group('Worksite', () {
    test('counts the free sites left this turn', () {
      final site = Worksite(upgrades: 1);
      expect(site.freeBuildSites(1), 0);
      expect(site.freeBuildSites(5), 1);
    });

    test('allows one research per turn', () {
      final site = Worksite();
      expect(site.canResearch, isTrue);
      site.research = 1;
      expect(site.canResearch, isFalse);
    });

    test('clear frees every site and the laboratory', () {
      final site = Worksite(upgrades: 2, research: 1)..clear();
      expect(site.upgrades, 0);
      expect(site.research, 0);
    });
  });
}
