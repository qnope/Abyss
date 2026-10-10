import '../l10n/app_localizations.dart';

/// The keys of the months in the `saveMonth` text, from January.
const List<String> _months = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun',
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

extension RelativeDate on DateTime {
  /// Tells in the player's language how long before [now] this date was:
  /// "à l'instant", "il y a 5 min", "il y a 2 h" earlier the same day,
  /// "hier", then a short date such as "5 oct.", with the year when it is
  /// not the one of [now].
  String relativeTo(AppLocalizations l10n, DateTime now) {
    final DateTime date = toLocal();
    final DateTime today = now.toLocal();
    final Duration elapsed = today.difference(date);
    if (elapsed.inMinutes < 1) return l10n.saveJustNow;
    if (elapsed.inHours < 1) return l10n.saveMinutesAgo(elapsed.inMinutes);
    final DateTime day = DateTime(date.year, date.month, date.day);
    if (day == DateTime(today.year, today.month, today.day)) {
      return l10n.saveHoursAgo(elapsed.inHours);
    }
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return l10n.saveYesterday;
    }
    final String month = l10n.saveMonth(_months[date.month - 1]);
    return date.year == today.year
        ? l10n.saveShortDate(date.day, month)
        : l10n.saveShortDateWithYear(date.day, month, date.year);
  }
}
