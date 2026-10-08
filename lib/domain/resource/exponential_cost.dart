import 'dart:math';

import 'resource_type.dart';

/// Growth of upgrade and research costs from one level to the next.
const double costGrowthPerLevel = 1.6;

/// Scales [base] by `1.6^step`, rounded to the nearest unit.
///
/// [step] is 0 for the first level, so the first cost equals [base].
Map<ResourceType, int> exponentialCost(Map<ResourceType, int> base, int step) {
  final factor = pow(costGrowthPerLevel, step);
  return {
    for (final entry in base.entries) entry.key: (entry.value * factor).round(),
  };
}
