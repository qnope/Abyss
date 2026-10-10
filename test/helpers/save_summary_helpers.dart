import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/save_outcome.dart';
import 'package:abyss/domain/game/save_summary.dart';
import 'package:abyss/domain/resource/resource_type.dart';

/// A save summary with sensible defaults, to tweak one field per test.
SaveSummary summaryOf({
  String playerName = 'Alice',
  int turn = 14,
  Difficulty difficulty = Difficulty.normal,
  SaveOutcome outcome = SaveOutcome.inProgress,
  int deepestLevel = 2,
  int headquartersLevel = 3,
  Map<ResourceType, int>? resources,
  DateTime? lastPlayedAt,
  bool volcanicKernelCaptured = false,
}) => SaveSummary(
  playerName: playerName,
  turn: turn,
  difficulty: difficulty,
  outcome: outcome,
  deepestLevel: deepestLevel,
  headquartersLevel: headquartersLevel,
  resources:
      resources ??
      const {
        ResourceType.algae: 412,
        ResourceType.coral: 298,
        ResourceType.ore: 186,
        ResourceType.energy: 74,
        ResourceType.pearl: 9,
      },
  lastPlayedAt: lastPlayedAt ?? DateTime(2026, 10, 10, 8),
  volcanicKernelCaptured: volcanicKernelCaptured,
);
