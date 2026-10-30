import 'package:flutter/widgets.dart';

import '../../../domain/volcano/kernel_garrison.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_segmented_theme.dart';
import '../common/segmented_bar.dart';
import 'army_places.dart';

/// Where the army is, at the bottom of the parade ground: « Toutes » then
/// each place holding units (« Niv. 1 », « Niv. 2 », « Niv. 3 »,
/// « Noyau »), each with its count, the [selected] one lit; a touch calls
/// [onSelected] with its place, [ArmyPlaces.all] for the whole army. A
/// screen reader hears « Niveau 2, 31 unités ».
class ArmyPlaceBar extends StatelessWidget {
  /// Room above and below the bar, and between it and the view's sides.
  static const _gap = 8.0, _side = 10.0;

  /// Height the bar takes at the bottom of the view, its gaps included.
  static const room = AbyssSegmentedTheme.height + 2 * _gap;

  final ArmyPlaces places;
  final int? selected;
  final ValueChanged<int?> onSelected;

  const ArmyPlaceBar({
    super.key,
    required this.places,
    required this.onSelected,
    this.selected = ArmyPlaces.all,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _side, vertical: _gap),
      child: SegmentedBar<int?>(
        segments: [
          for (final place in [ArmyPlaces.all, ...places.held])
            Segment(
              value: place,
              label: _short(l10n, place),
              detail: '${places.totalAt(place)}',
              semanticsLabel:
                  '${_long(l10n, place)}, '
                  '${l10n.unitTotalCount(places.totalAt(place))}',
            ),
        ],
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  /// The name of [place] on its segment.
  static String _short(AppLocalizations l10n, int? place) => switch (place) {
    ArmyPlaces.all => l10n.armyPlaceAll,
    KernelGarrison.stockKey => l10n.unitPlaceKernel,
    final int level => l10n.baseLevelShort(level),
  };

  /// The name of [place] as a screen reader says it.
  static String _long(AppLocalizations l10n, int? place) => switch (place) {
    ArmyPlaces.all => l10n.armyPlaceAll,
    KernelGarrison.stockKey => l10n.unitPlaceKernel,
    final int level => l10n.baseLevel(level),
  };
}
