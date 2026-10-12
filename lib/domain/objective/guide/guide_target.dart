import '../../building/building_type.dart';
import '../../map/grid_position.dart';
import '../../tech/tech_branch.dart';
import '../../unit/unit_type.dart';
import 'guide_area.dart';

/// What the guide's halo surrounds: the [area] of the screen to open, then
/// the item to touch there, such as a card or a cell of the map; or the
/// button that ends the turn.
class GuideTarget {
  /// Place to open first, `null` for the end of the turn, always shown.
  final GuideArea? area;

  /// Building whose card is surrounded, on the base.
  final BuildingType? building;

  /// Unit whose card is surrounded, in the army.
  final UnitType? unit;

  /// Branches whose medallion ([_techLevel] 0, to unlock them) or first
  /// node ([_techLevel] 1, to research it) is surrounded.
  final Set<TechBranch> _branches;
  final int _techLevel;

  /// Whether the button that ends the turn is surrounded.
  final bool endTurn;

  /// Level of the map whose [cell] is surrounded, `null` for no cell.
  final int? level;

  /// Cell of the map surrounded, on [level].
  final GridPosition? cell;

  /// Whether the button that fills the kernel's garrison is surrounded,
  /// on the sheet of the kernel at [cell].
  final bool garrison;

  /// The card of [building], on the base.
  const GuideTarget.building(BuildingType building)
    : this._(GuideArea.base, building: building);

  /// The card of [unit], in the army.
  const GuideTarget.unit(UnitType unit) : this._(GuideArea.army, unit: unit);

  /// The map, to explore it.
  const GuideTarget.map() : this._(GuideArea.map);

  /// The cell [cell] of the map of [level], such as a post to take.
  const GuideTarget.cell(int level, GridPosition cell)
    : this._(GuideArea.map, level: level, cell: cell);

  /// The kernel at [kernel] on [level], then the button of its sheet that
  /// fills its garrison.
  const GuideTarget.garrison(int level, GridPosition kernel)
    : this._(GuideArea.map, level: level, cell: kernel, garrison: true);

  /// The medallions of [branches], to unlock one.
  const GuideTarget.unlock(Set<TechBranch> branches)
    : this._(GuideArea.research, branches: branches);

  /// The first node of [branches], to research it.
  const GuideTarget.research(Set<TechBranch> branches)
    : this._(GuideArea.research, branches: branches, techLevel: 1);

  /// The button that ends the turn.
  const GuideTarget.endTurn() : this._(null, endTurn: true);

  const GuideTarget._(
    this.area, {
    this.building,
    this.unit,
    Set<TechBranch> branches = const {},
    int techLevel = 0,
    this.endTurn = false,
    this.level,
    this.cell,
    this.garrison = false,
  }) : _branches = branches,
       _techLevel = techLevel;

  bool isBuilding(BuildingType type) => building == type;

  bool isUnit(UnitType type) => unit == type;

  /// Whether the cell ([x], [y]) of the map of [onLevel] is surrounded.
  bool isCell(int onLevel, int x, int y) =>
      level == onLevel && cell?.x == x && cell?.y == y;

  /// Whether the medallion of [branch] is surrounded.
  bool isBranch(TechBranch branch) =>
      _techLevel == 0 && _branches.contains(branch);

  /// Whether the node of [branch] at [level] is surrounded.
  bool isTechNode(TechBranch branch, int level) =>
      _techLevel > 0 && level == _techLevel && _branches.contains(branch);

  @override
  bool operator ==(Object other) =>
      other is GuideTarget &&
      other.area == area &&
      other.building == building &&
      other.unit == unit &&
      other._techLevel == _techLevel &&
      other.endTurn == endTurn &&
      other.level == level &&
      other.cell == cell &&
      other.garrison == garrison &&
      other._branches.length == _branches.length &&
      other._branches.containsAll(_branches);

  @override
  int get hashCode => Object.hash(
    area,
    building,
    unit,
    _techLevel,
    endTurn,
    level,
    cell,
    garrison,
    Object.hashAllUnordered(_branches),
  );

  @override
  String toString() =>
      'GuideTarget(${area?.name ?? 'endTurn'}, '
      '${building?.name ?? unit?.name ?? cell ?? _branches.map((b) => b.name)}'
      '${level == null ? '' : ' on $level'})';
}
