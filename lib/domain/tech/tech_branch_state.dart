import 'package:hive/hive.dart';
import 'tech_branch.dart';

part 'tech_branch_state.g.dart';

@HiveType(typeId: 7)
class TechBranchState extends HiveObject {
  @HiveField(0)
  final TechBranch branch;

  @HiveField(1)
  bool unlocked;

  @HiveField(2)
  int researchLevel; // 0 = none, 1–5 = researched nodes

  TechBranchState({
    required this.branch,
    this.unlocked = false,
    this.researchLevel = 0,
  });
}
