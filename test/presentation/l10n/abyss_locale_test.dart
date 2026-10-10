import 'dart:ui';

import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AbyssLocale.resolve', () {
    test('keeps French on a French device', () {
      expect(AbyssLocale.resolve([const Locale('fr', 'FR')]), AbyssLocale.fr);
      expect(AbyssLocale.resolve([const Locale('fr', 'CA')]), AbyssLocale.fr);
    });

    test('picks Spanish on any Spanish device', () {
      expect(AbyssLocale.resolve([const Locale('es', 'ES')]), AbyssLocale.es);
      expect(AbyssLocale.resolve([const Locale('es', 'MX')]), AbyssLocale.es);
    });

    test('falls back to English for every other language', () {
      expect(AbyssLocale.resolve([const Locale('en', 'US')]), AbyssLocale.en);
      expect(AbyssLocale.resolve([const Locale('de')]), AbyssLocale.en);
      expect(AbyssLocale.resolve([const Locale('ja', 'JP')]), AbyssLocale.en);
    });

    test('follows the device language, not the later preferences', () {
      final locales = [const Locale('de'), const Locale('fr')];
      expect(AbyssLocale.resolve(locales), AbyssLocale.en);
    });

    test('falls back to English when the device gives no language', () {
      expect(AbyssLocale.resolve(null), AbyssLocale.en);
      expect(AbyssLocale.resolve(const []), AbyssLocale.en);
    });

    test('supports exactly French, English and Spanish', () {
      expect(AbyssLocale.supported, [
        AbyssLocale.fr,
        AbyssLocale.en,
        AbyssLocale.es,
      ]);
    });
  });
}
