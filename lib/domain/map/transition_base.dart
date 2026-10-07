import 'package:hive_ce/hive.dart';
import 'transition_base_type.dart';

part 'transition_base.g.dart';

@HiveType(typeId: 32)
class TransitionBase {
  @HiveField(0)
  final TransitionBaseType type;

  @HiveField(1)
  final String name;

  @HiveField(2)
  String? capturedBy;

  TransitionBase({
    required this.type,
    required this.name,
    this.capturedBy,
  });

  bool get isCaptured => capturedBy != null;

  int get difficulty =>
      type == TransitionBaseType.faille ? 4 : 5;

  /// Pearls the base yields each turn once captured.
  int get pearlsPerTurn =>
      type == TransitionBaseType.faille ? 2 : 3;

  int get targetLevel =>
      type == TransitionBaseType.faille ? 2 : 3;
}
