/// The language the player wants the game in.
///
/// [automatic] follows the device; the others force a language whatever
/// the device speaks.
enum LanguageChoice {
  automatic(null),
  french('fr'),
  english('en'),
  spanish('es');

  /// Stable code the choice is saved under; null for [automatic], which is
  /// never stored.
  final String? code;

  const LanguageChoice(this.code);

  /// The choice saved under [code]; [automatic] for a missing or unknown
  /// one.
  static LanguageChoice fromCode(String? code) => values.firstWhere(
    (choice) => choice.code == code,
    orElse: () => automatic,
  );
}
