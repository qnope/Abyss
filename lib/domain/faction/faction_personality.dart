import 'package:hive_ce/hive.dart';

part 'faction_personality.g.dart';

/// The ten ways a faction goes after the volcanic kernel.
///
/// Only the catalogue and the names exist for now: every personality
/// plays the same economic brain until its own strategy is written.
@HiveType(typeId: 56)
enum FactionPersonality {
  @HiveField(0)
  wreckPillagers('Les Pillards de l\'Épave'),
  @HiveField(1)
  pearlOrder('L\'Ordre de Nacre'),
  @HiveField(2)
  anglerCult('Le Culte de la Baudroie'),
  @HiveField(3)
  murenaHorde('La Horde des Murènes'),
  @HiveField(4)
  siphonophoreGuild('La Guilde des Siphonophores'),
  @HiveField(5)
  silenceMonks('Les Moines du Silence'),
  @HiveField(6)
  currentNomads('Les Nomades du Courant'),
  @HiveField(7)
  pyrosomeHive('La Ruche des Pyrosomes'),
  @HiveField(8)
  magmaSmiths('Les Forgerons du Magma'),
  @HiveField(9)
  krakenFaithful('Les Fidèles du Kraken');

  const FactionPersonality(this.label);

  /// Name of the faction, in French like the rest of the domain texts.
  final String label;
}
