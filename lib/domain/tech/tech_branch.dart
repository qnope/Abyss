import 'package:hive/hive.dart';

part 'tech_branch.g.dart';

@HiveType(typeId: 6)
enum TechBranch {
  @HiveField(0) military,
  @HiveField(1) resources,
  @HiveField(2) explorer,
}
