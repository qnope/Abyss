import 'grid_position.dart';
import 'cell_content_type.dart';

class ExplorationResult {
  final GridPosition target;
  final int newCellsRevealed;
  final List<CellContentType> notableContent;

  const ExplorationResult({
    required this.target,
    required this.newCellsRevealed,
    this.notableContent = const [],
  });
}
