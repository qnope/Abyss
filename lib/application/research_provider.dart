import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/domain/models/technology.dart';

class ResearchNotifier extends StateNotifier<List<Technology>> {
  ResearchNotifier() : super([]);

  void setTechnologies(List<Technology> techs) {
    state = techs;
  }

  void startResearch(String techId) {
    state = [
      for (final t in state)
        if (t.techId == techId)
          t.copyWith(startTime: DateTime.now())
        else
          t,
    ];
  }

  void completeResearch(String techId) {
    state = [
      for (final t in state)
        if (t.techId == techId)
          t.copyWith(isCompleted: true, completionPercentage: 100.0, endTime: DateTime.now())
        else
          t,
    ];
  }

  void updateProgress(String techId, double percentage) {
    state = [
      for (final t in state)
        if (t.techId == techId)
          t.copyWith(completionPercentage: percentage)
        else
          t,
    ];
  }
}

final researchProvider =
    StateNotifierProvider<ResearchNotifier, List<Technology>>((ref) {
  return ResearchNotifier();
});
