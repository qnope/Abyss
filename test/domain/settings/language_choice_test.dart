import 'package:abyss/domain/settings/language_choice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguageChoice', () {
    test('offers automatic first, then French, English and Spanish', () {
      expect(LanguageChoice.values, [
        LanguageChoice.automatic,
        LanguageChoice.french,
        LanguageChoice.english,
        LanguageChoice.spanish,
      ]);
    });

    test('stores each language under its code, automatic under none', () {
      expect(LanguageChoice.automatic.code, isNull);
      expect(LanguageChoice.french.code, 'fr');
      expect(LanguageChoice.english.code, 'en');
      expect(LanguageChoice.spanish.code, 'es');
    });

    test('reads back every choice from its code', () {
      for (final choice in LanguageChoice.values) {
        expect(LanguageChoice.fromCode(choice.code), choice);
      }
    });

    test('reads an unknown or missing code as automatic', () {
      expect(LanguageChoice.fromCode(null), LanguageChoice.automatic);
      expect(LanguageChoice.fromCode('de'), LanguageChoice.automatic);
      expect(LanguageChoice.fromCode(''), LanguageChoice.automatic);
    });
  });
}
