import 'dart:math';

import 'package:abysses/core/constants/game_constants.dart';

enum ActivityTier { active, semiActive, dormant }

class ActivityTierManager {
  final Map<int, ActivityTier> _colonyTiers = {};

  ActivityTier getTier(int colonyId) =>
      _colonyTiers[colonyId] ?? ActivityTier.dormant;

  List<int> getColoniesInTier(ActivityTier tier) => _colonyTiers.entries
      .where((e) => e.value == tier)
      .map((e) => e.key)
      .toList();

  void updateTier({
    required int colonyId,
    required double playerX,
    required double playerY,
    required double colonyX,
    required double colonyY,
  }) {
    final distance =
        sqrt(pow(playerX - colonyX, 2) + pow(playerY - colonyY, 2));
    final currentTier = _colonyTiers[colonyId] ?? ActivityTier.dormant;
    _colonyTiers[colonyId] = _calculateTier(distance, currentTier);
  }

  ActivityTier _calculateTier(double distance, ActivityTier currentTier) {
    switch (currentTier) {
      case ActivityTier.active:
        if (distance >
            GameConstants.activeRadius + GameConstants.activeBuffer) {
          return ActivityTier.semiActive;
        }
        return ActivityTier.active;
      case ActivityTier.semiActive:
        if (distance <
            GameConstants.activeRadius - GameConstants.activeBuffer) {
          return ActivityTier.active;
        }
        if (distance >
            GameConstants.semiActiveRadius +
                GameConstants.semiActiveBuffer) {
          return ActivityTier.dormant;
        }
        return ActivityTier.semiActive;
      case ActivityTier.dormant:
        if (distance <
            GameConstants.semiActiveRadius -
                GameConstants.semiActiveBuffer) {
          return ActivityTier.semiActive;
        }
        return ActivityTier.dormant;
    }
  }
}
