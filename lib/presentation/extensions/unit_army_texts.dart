import '../../domain/unit/unit_cost_calculator.dart';
import '../../domain/unit/unit_type.dart';
import '../l10n/app_localizations.dart';
import 'unit_type_extensions.dart';

/// The texts of a squad on the army's parade ground.
extension UnitArmyTexts on UnitType {
  /// The name on the plaque of a squad of [count] units: in the singular
  /// for one unit or a [locked] squad (« Gardien »), in the plural for
  /// any other count, none included (« Briseurs »).
  String plaqueName(AppLocalizations l10n, int count, {bool locked = false}) =>
      locked || count == 1 ? displayName(l10n) : _plural(l10n);

  /// What a screen reader says of the squad: its name and how many units
  /// it holds, whether it can recruit this turn; or that it is [locked]
  /// and the barracks level it waits for.
  /// « Harponneurs, 22 unités, recrutable », « Gardien, verrouillé,
  /// Caserne niveau 3 ».
  String armyLabel(
    AppLocalizations l10n, {
    required int count,
    required bool locked,
    required bool recruitable,
  }) => [
    plaqueName(l10n, count, locked: locked),
    if (locked)
      l10n.armyUnitLocked(UnitCostCalculator().unlockLevel(this))
    else ...[
      l10n.unitTotalCount(count),
      if (recruitable) l10n.armyUnitRecruitable,
    ],
  ].join(', ');

  /// The plural of the type's name, capitalised: the count of two units
  /// (« 2 harponneurs ») without its number.
  String _plural(AppLocalizations l10n) {
    final name = units(l10n, 2).replaceFirst(RegExp(r'^\d+\s*'), '');
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}
