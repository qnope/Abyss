import 'package:flutter/material.dart';
import '../../domain/game/difficulty.dart';
import '../theme/abyss_colors.dart';

extension DifficultyInfo on Difficulty {
  String get displayName => switch (this) {
    Difficulty.easy => 'Facile',
    Difficulty.normal => 'Normal',
    Difficulty.hard => 'Difficile',
  };

  String get description => switch (this) {
    Difficulty.easy => 'Plus de ressources, des monstres moins nombreux.',
    Difficulty.normal => 'L\'équilibre prévu pour les abysses.',
    Difficulty.hard => 'Moins de ressources, des monstres plus nombreux.',
  };

  Color get color => switch (this) {
    Difficulty.easy => AbyssColors.success,
    Difficulty.normal => AbyssColors.biolumCyan,
    Difficulty.hard => AbyssColors.error,
  };
}
