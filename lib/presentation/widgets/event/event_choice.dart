/// One button of an event card: the option and what it does, in figures.
class EventChoice {
  /// e.g. « Échanger 100 Algues contre 70 Minerai ».
  final String label;

  /// Whether it takes the first option, otherwise the prudent one.
  final bool accept;

  /// Why the option is closed now, or `null` when it is open.
  final String? refusal;

  const EventChoice({
    required this.label,
    required this.accept,
    this.refusal,
  });
}
