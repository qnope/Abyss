import 'package:flutter/material.dart';
import '../../domain/map/terrain_type.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension TerrainTypeExtensions on TerrainType {
  String label(AppLocalizations l10n) => l10n.terrainPlain;

  String get svgPath => 'assets/icons/terrain/plain.svg';

  /// The diamond tiles of the sea floor laid on the isometric map, one
  /// picked per cell so the floor never reads as a pattern.
  List<String> get tileSvgPaths => const [
        'assets/icons/terrain/plain_iso_1.svg',
        'assets/icons/terrain/plain_iso_2.svg',
        'assets/icons/terrain/plain_iso_3.svg',
      ];

  Color get color => AbyssColors.plainBlue;

  bool get isOpaque => false;
}
