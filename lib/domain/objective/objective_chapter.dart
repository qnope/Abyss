/// The six chapters of the objectives, from the first building to the
/// victory; the first one is the tutorial.
enum ObjectiveChapter {
  installation('Installation'),
  reef('Le récif'),
  rift('La Faille'),
  chimney('La Cheminée'),
  kernel('Le Noyau'),
  awakening('Le réveil');

  /// Title shown to the player.
  final String title;

  const ObjectiveChapter(this.title);
}
