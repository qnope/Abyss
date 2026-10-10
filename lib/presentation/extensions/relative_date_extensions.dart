const List<String> _shortMonths = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

extension RelativeDate on DateTime {
  /// Tells in French how long before [now] this date was: "à l'instant",
  /// "il y a 5 min", "il y a 2 h" earlier the same day, "hier", then a short
  /// date such as "5 oct.", with the year when it is not the one of [now].
  String relativeTo(DateTime now) {
    final DateTime date = toLocal();
    final DateTime today = now.toLocal();
    final Duration elapsed = today.difference(date);
    if (elapsed.inMinutes < 1) return "à l'instant";
    if (elapsed.inHours < 1) return 'il y a ${elapsed.inMinutes} min';
    final DateTime day = DateTime(date.year, date.month, date.day);
    if (day == DateTime(today.year, today.month, today.day)) {
      return 'il y a ${elapsed.inHours} h';
    }
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return 'hier';
    }
    final String short = '${date.day} ${_shortMonths[date.month - 1]}';
    return date.year == today.year ? short : '$short ${date.year}';
  }
}
