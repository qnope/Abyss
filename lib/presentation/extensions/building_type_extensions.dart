import 'package:flutter/material.dart';
import '../../domain/building_type.dart';
import '../theme/abyss_colors.dart';

extension BuildingTypeColor on BuildingType {
  Color get color => switch (this) {
    BuildingType.headquarters => AbyssColors.biolumPurple,
  };
}

extension BuildingTypeInfo on BuildingType {
  String get displayName => switch (this) {
    BuildingType.headquarters => 'Quartier Général',
  };

  String get description => switch (this) {
    BuildingType.headquarters =>
      'Centre de commandement de votre base sous-marine. '
      'Son niveau détermine les capacités de votre colonie.',
  };

  String get iconPath => switch (this) {
    BuildingType.headquarters => 'assets/icons/buildings/headquarters.svg',
  };
}
