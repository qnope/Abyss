import '../../../../../domain/unit/unit_stats.dart';
import '../../../../../domain/unit/unit_type.dart';

/// The unit type leading an army [sent] to fight, whose image stands for
/// the whole army: the type sent in the largest number; between types
/// sent as many, the stronger attacker, then the first type. `null` for
/// an empty army.
UnitType? strikeLeadOf(Map<UnitType, int> sent) {
  UnitType? lead;
  for (final type in UnitType.values) {
    final count = sent[type] ?? 0;
    if (count <= 0) continue;
    if (lead == null || _leads(type, count, lead, sent[lead]!)) lead = type;
  }
  return lead;
}

/// Whether [type], sent [count] times, leads before [other], sent
/// [otherCount] times and listed before it.
bool _leads(UnitType type, int count, UnitType other, int otherCount) {
  if (count != otherCount) return count > otherCount;
  return UnitStats.forType(type).atk > UnitStats.forType(other).atk;
}
