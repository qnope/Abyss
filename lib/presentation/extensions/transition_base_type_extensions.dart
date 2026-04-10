import 'package:flutter/material.dart';
import '../../domain/map/transition_base_type.dart';
import '../theme/abyss_colors.dart';

extension TransitionBaseTypeExtensions on TransitionBaseType {
  String get displayName => switch (this) {
    TransitionBaseType.faille => 'Faille Abyssale',
    TransitionBaseType.cheminee => 'Cheminee du Noyau',
  };

  String get description => switch (this) {
    TransitionBaseType.faille => 'Passage vers les profondeurs',
    TransitionBaseType.cheminee => 'Passage vers le noyau',
  };

  Color get glowColor => switch (this) {
    TransitionBaseType.faille => AbyssColors.biolumCyan,
    TransitionBaseType.cheminee => AbyssColors.energyYellow,
  };
}
