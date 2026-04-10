import 'package:hive/hive.dart';

part 'transition_base_type.g.dart';

@HiveType(typeId: 31)
enum TransitionBaseType {
  @HiveField(0) faille,
  @HiveField(1) cheminee,
}
