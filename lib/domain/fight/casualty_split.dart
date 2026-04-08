import 'combatant.dart';

class CasualtySplit {
  final List<Combatant> wounded;
  final List<Combatant> dead;

  const CasualtySplit({required this.wounded, required this.dead});
}
