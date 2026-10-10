import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

extension LocalizedDecimal on num {
  /// This number with [digits] decimals, in the player's language:
  /// "1,5" in French and Spanish, "1.5" in English.
  String decimal(AppLocalizations l10n, {int digits = 1}) =>
      NumberFormat.decimalPatternDigits(
        locale: l10n.localeName,
        decimalDigits: digits,
      ).format(this);
}
