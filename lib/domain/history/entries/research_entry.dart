part of '../history_entry.dart';

/// History entry recording a tech branch unlock or a tech research.
@HiveType(typeId: 20)
class ResearchEntry extends HistoryEntry {
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
  final TechBranch branch;

  @HiveField(5)
  final bool isUnlock;

  @HiveField(6)
  final int? newLevel;

  ResearchEntry({
    required this.turn,
    required this.branch,
    required this.isUnlock,
    this.newLevel,
    this.subtitle,
  }) : category = HistoryEntryCategory.research,
       title = _buildResearchTitle(branch, isUnlock, newLevel);
}

String _buildResearchTitle(TechBranch branch, bool isUnlock, int? newLevel) {
  final label = _branchLabel(branch);
  if (isUnlock) {
    return '$label débloquée';
  }
  if (newLevel != null) {
    return '$label niv $newLevel';
  }
  return '$label améliorée';
}

String _branchLabel(TechBranch branch) => switch (branch) {
  TechBranch.military => 'Militaire',
  TechBranch.resources => 'Ressources',
  TechBranch.explorer => 'Explorateur',
};
