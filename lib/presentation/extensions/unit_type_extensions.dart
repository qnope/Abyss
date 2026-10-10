import 'package:flutter/material.dart';
import '../../domain/unit/unit_type.dart';
import '../l10n/app_localizations.dart';

extension UnitTypeExtensions on UnitType {
  String displayName(AppLocalizations l10n) => switch (this) {
    UnitType.scout => l10n.unitScoutName,
    UnitType.harpoonist => l10n.unitHarpoonistName,
    UnitType.guardian => l10n.unitGuardianName,
    UnitType.domeBreaker => l10n.unitDomeBreakerName,
    UnitType.abyssAdmiral => l10n.unitAbyssAdmiralName,
    UnitType.saboteur => l10n.unitSaboteurName,
  };

  Color get color => switch (this) {
    UnitType.scout => const Color(0xFF0D47A1),
    UnitType.harpoonist => const Color(0xFFBF360C),
    UnitType.guardian => const Color(0xFF607D8B),
    UnitType.domeBreaker => const Color(0xFFE65100),
    UnitType.abyssAdmiral => const Color(0xFF4A148C),
    UnitType.saboteur => const Color(0xFF1B5E20),
  };

  String get iconPath => switch (this) {
    UnitType.scout => 'assets/icons/units/scout.svg',
    UnitType.harpoonist => 'assets/icons/units/harpoonist.svg',
    UnitType.guardian => 'assets/icons/units/guardian.svg',
    UnitType.domeBreaker => 'assets/icons/units/dome_breaker.svg',
    UnitType.abyssAdmiral => 'assets/icons/units/abyss_admiral.svg',
    UnitType.saboteur => 'assets/icons/units/saboteur.svg',
  };

  String role(AppLocalizations l10n) => switch (this) {
    UnitType.scout => l10n.unitScoutRole,
    UnitType.harpoonist => l10n.unitHarpoonistRole,
    UnitType.guardian => l10n.unitGuardianRole,
    UnitType.domeBreaker => l10n.unitDomeBreakerRole,
    UnitType.abyssAdmiral => l10n.unitAbyssAdmiralRole,
    UnitType.saboteur => l10n.unitSaboteurRole,
  };

  String roleEffect(AppLocalizations l10n) => switch (this) {
    UnitType.scout => l10n.unitScoutRoleEffect,
    UnitType.harpoonist => l10n.unitHarpoonistRoleEffect,
    UnitType.guardian => l10n.unitGuardianRoleEffect,
    UnitType.domeBreaker => l10n.unitDomeBreakerRoleEffect,
    UnitType.abyssAdmiral => l10n.unitAbyssAdmiralRoleEffect,
    UnitType.saboteur => l10n.unitSaboteurRoleEffect,
  };
}
