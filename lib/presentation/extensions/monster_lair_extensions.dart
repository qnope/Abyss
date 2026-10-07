import '../../domain/map/monster_lair.dart';

/// French wording for a monster group, used by raid alerts and reports.
extension MonsterLairDisplay on MonsterLair {
  /// e.g. "22 monstres niv. 1".
  String get waveLabel =>
      '$unitCount ${unitCount > 1 ? 'monstres' : 'monstre'} niv. $level';
}
