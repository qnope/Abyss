import 'package:hive/hive.dart';
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

  int get targetLevel =>
      type == TransitionBaseType.faille ? 2 : 3;
}
