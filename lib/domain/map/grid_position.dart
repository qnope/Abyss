import 'package:hive/hive.dart';

part 'grid_position.g.dart';

@HiveType(typeId: 15)
class GridPosition {
  @HiveField(0)
  final int x;

  @HiveField(1)
  final int y;

  GridPosition({required this.x, required this.y});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'GridPosition($x, $y)';
}
