import '../../../domain/event/event_effects.dart';
import '../../../domain/event/event_rules.dart';
import '../../../domain/event/random_event_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/event_state_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../raid/raid_due_warning.dart';
import 'event_choice.dart';

/// French wording of the event cards of [player], with the figures of
/// [EventRules] and of the offer drawn.
class EventCardTexts {
  final AppLocalizations l10n;
  final Game game;
  final Player player;

  const EventCardTexts(this.l10n, this.game, this.player);

  static const _turns = EventRules.effectTurns;
  static const _percent = EventRules.currentPercent;

  /// Two lines telling what happens.
  List<String> linesOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => const [
      'Un courant chaud traverse la base.',
      'Il dope la production, mais son remous fait du bruit.',
    ],
    RandomEventType.coldCurrent => const [
      'Un courant froid glace les serres.',
      'Sans chauffage, les algues poussent moins.',
    ],
    RandomEventType.predators => [
      'Un banc de prédateurs rôde autour de la base.',
      _predatorsLine(),
    ],
    RandomEventType.survivors => const [
      'Une capsule échouée lance une fusée de détresse.',
      'Ses survivants peuvent rejoindre la base, mais mangeront des algues.',
    ],
    RandomEventType.caravan => const [
      'Une caravane de tortues passe près de la base.',
      'Son crabe marchand propose un échange.',
    ],
    RandomEventType.storm => const [
      'Exploration impossible pendant ${EventRules.stormTurns} tours.',
      'La tempête couvre le bruit : jauge '
          '−${EventRules.stormNoiseRelief}.',
    ],
    RandomEventType.wreck => [
      'Une épave a coulé au bord de la zone explorée.',
      'Explore-la avec un Éclaireur puis fouille-la avant '
          '${_wreckTurns()} tours (+${EventRules.wreckNoise} bruit).',
    ],
  };

  /// The first option then the prudent one; none for an event that
  /// applies at once.
  List<EventChoice> choicesOf(RandomEventType type) {
    final (String, String)? labels = _labelsOf(type);
    if (labels == null) return const [];
    return [
      EventChoice(
        label: labels.$1,
        accept: true,
        refusal: EventEffects.of(type).refusal(game, player),
      ),
      EventChoice(label: labels.$2, accept: false),
    ];
  }

  (String, String)? _labelsOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => (
      'Exploiter (+$_percent % algues, corail, minerai pendant $_turns '
          'tours, +${EventRules.warmNoisePerTurn} bruit/tour)',
      'Laisser passer',
    ),
    RandomEventType.coldCurrent => (
      'Chauffer les serres (−${EventRules.heatingEnergyPerTurn} '
          'énergie/tour pendant $_turns tours)',
      "Subir (−$_percent % d'algues pendant $_turns tours)",
    ),
    RandomEventType.predators => (
      "L'affronter (${player.eventState.predatorWave?.totalCount ?? 0} "
          'monstres, fin du tour)',
      "L'appâter (−${_bait()} algues)",
    ),
    RandomEventType.survivors => (_welcome(), 'Refuser'),
    RandomEventType.caravan => (_trade(), 'Refuser'),
    RandomEventType.storm || RandomEventType.wreck => null,
  };

  String _predatorsLine() {
    final wave = player.eventState.predatorWave;
    final defenders = RaidDueWarning.defendersLabel(
      RaidDueWarning.defenderCountOf(player),
    );
    if (wave == null) return 'Ils guettent la base.';
    return '${wave.waveLabel(l10n)} contre $defenders du niveau 1.';
  }

  int _bait() =>
      (player.resources[ResourceType.algae]?.amount ?? 0) *
      EventRules.baitAlgaePercent ~/
      100;

  String _welcome() {
    final int count = player.eventState.survivors ?? 0;
    return 'Accueillir $count Harponneur${count > 1 ? 's' : ''}';
  }

  String _trade() {
    final from = player.eventState.tradeFrom?.displayName(l10n) ?? '?';
    final to = player.eventState.tradeTo?.displayName(l10n) ?? '?';
    return 'Échanger ${EventRules.caravanGive} $from contre '
        '${EventRules.caravanGet} $to';
  }

  int _wreckTurns() {
    final until = player.eventState.wreckUntilTurn;
    return until == null ? EventRules.wreckTurns : turnsLeft(until, game.turn);
  }
}
