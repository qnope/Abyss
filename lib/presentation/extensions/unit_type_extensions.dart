import 'package:flutter/material.dart';
import '../../domain/unit_type.dart';

extension UnitTypeExtensions on UnitType {
  String get displayName => switch (this) {
    UnitType.scout => 'Eclaireur',
    UnitType.harpoonist => 'Harponneur',
    UnitType.guardian => 'Gardien',
    UnitType.domeBreaker => 'Briseur',
    UnitType.siphoner => 'Siphonneur',
    UnitType.saboteur => 'Saboteur',
  };

  Color get color => switch (this) {
    UnitType.scout => const Color(0xFF0D47A1),
    UnitType.harpoonist => const Color(0xFFBF360C),
    UnitType.guardian => const Color(0xFF607D8B),
    UnitType.domeBreaker => const Color(0xFFE65100),
    UnitType.siphoner => const Color(0xFF4A148C),
    UnitType.saboteur => const Color(0xFF1B5E20),
  };

  String get iconPath => switch (this) {
    UnitType.scout => 'assets/icons/units/scout.svg',
    UnitType.harpoonist => 'assets/icons/units/harpoonist.svg',
    UnitType.guardian => 'assets/icons/units/guardian.svg',
    UnitType.domeBreaker => 'assets/icons/units/dome_breaker.svg',
    UnitType.siphoner => 'assets/icons/units/siphoner.svg',
    UnitType.saboteur => 'assets/icons/units/saboteur.svg',
  };

  String get role => switch (this) {
    UnitType.scout => 'Eclaireur',
    UnitType.harpoonist => 'DPS',
    UnitType.guardian => 'Tank',
    UnitType.domeBreaker => 'Siege',
    UnitType.siphoner => 'Voleur',
    UnitType.saboteur => 'Verre-canon',
  };
}
