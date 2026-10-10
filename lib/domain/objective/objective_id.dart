import 'package:hive_ce/hive.dart';

part 'objective_id.g.dart';

/// Every objective of the main thread, in the order they are given.
@HiveType(typeId: 53)
enum ObjectiveId {
  @HiveField(0)
  hqLevel1,
  @HiveField(1)
  algaeFarm,
  @HiveField(2)
  mines,
  @HiveField(3)
  solarPanel,
  @HiveField(4)
  hqLevel2,
  @HiveField(5)
  barracksAndScouts,
  @HiveField(6)
  explore,
  @HiveField(7)
  laboratoryAndResearch,
  @HiveField(8)
  firstRaid,
  @HiveField(9)
  takeLair,
  @HiveField(10)
  hqLevel5,
  @HiveField(11)
  coralCitadel,
  @HiveField(12)
  takeFaille,
  @HiveField(13)
  descentModule,
  @HiveField(14)
  descendLevel2,
  @HiveField(15)
  hqLevel8,
  @HiveField(16)
  takeCheminee,
  @HiveField(17)
  pressureCapsule,
  @HiveField(18)
  descendLevel3,
  @HiveField(19)
  hqLevel10,
  @HiveField(20)
  takeKernel,
  @HiveField(21)
  kernelLevel1,
  @HiveField(22)
  kernelLevel5,
  @HiveField(23)
  kernelLevel10,
}
