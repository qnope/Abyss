import 'package:flutter/material.dart';
import '../../domain/map/terrain_type.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension TerrainTypeExtensions on TerrainType {
  String label(AppLocalizations l10n) => l10n.terrainPlain;

  String get svgPath => 'assets/icons/terrain/plain.svg';

  Color get color => AbyssColors.plainBlue;

  bool get isOpaque => false;
}
