/// How the wreck of a player left the map at the end of a turn.
class WreckEnding {
  /// `true` when searched during the turn, `false` when it sank unsearched.
  final bool searched;

  /// Last turn, inclusive, it could be searched.
  final int untilTurn;

  const WreckEnding({required this.searched, required this.untilTurn});
}
