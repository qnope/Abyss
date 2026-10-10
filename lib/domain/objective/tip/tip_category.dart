/// The part of the game a tip card explains, a section of the Guide.
enum TipCategory {
  base('Base'),
  threats('Menaces'),
  map('Carte'),
  events('Événements');

  /// Title of the section, in French.
  final String label;

  const TipCategory(this.label);
}
