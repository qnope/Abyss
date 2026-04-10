part of '../history_entry.dart';

/// History entry recording the capture of a transition base.
///
/// Carries the full [FightResult] so the combat can be replayed from the
/// history view, same pattern as [CombatEntry].
@HiveType(typeId: 34)
class CaptureEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
  final String? subtitle;

  @HiveField(4)
  final String transitionBaseName;

  @HiveField(5)
  final FightResult fightResult;

  CaptureEntry({
    required this.turn,
    required this.transitionBaseName,
    required this.fightResult,
    this.subtitle,
  }) : category = HistoryEntryCategory.capture,
       title = 'Capture: $transitionBaseName';
}
