import '../../../domain/event/event_effects.dart';
import '../../../domain/event/event_rules.dart';
import '../../../domain/event/random_event_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../extensions/event_state_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../raid/raid_due_warning.dart';
import 'event_choice.dart';

/// Wording of the event cards of [player], in the language of [l10n],
/// with the figures of [EventRules] and of the offer drawn.
class EventCardTexts {
  final AppLocalizations l10n;
  final Game game;
  final Player player;

  const EventCardTexts(this.l10n, this.game, this.player);

  static const _turns = EventRules.effectTurns;
  static const _percent = EventRules.currentPercent;

  /// Two lines telling what happens.
  List<String> linesOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => [
      l10n.eventCardWarmLine1,
      l10n.eventCardWarmLine2,
    ],
    RandomEventType.coldCurrent => [
      l10n.eventCardColdLine1,
      l10n.eventCardColdLine2,
    ],
    RandomEventType.predators => [
      l10n.eventCardPredatorsLine1,
      _predatorsLine(),
    ],
    RandomEventType.survivors => [
      l10n.eventCardSurvivorsLine1,
      l10n.eventCardSurvivorsLine2,
    ],
    RandomEventType.caravan => [
      l10n.eventCardCaravanLine1,
      l10n.eventCardCaravanLine2,
    ],
    RandomEventType.storm => [
      l10n.eventCardStormLine1(EventRules.stormTurns),
      l10n.eventCardStormLine2(EventRules.stormNoiseRelief),
    ],
    RandomEventType.wreck => [
      l10n.eventCardWreckLine1,
      l10n.eventCardWreckLine2(_wreckTurns(), EventRules.wreckNoise),
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
        refusal: EventEffects.of(type).refusal(game, player)?.message(l10n),
      ),
      EventChoice(label: labels.$2, accept: false),
    ];
  }

  (String, String)? _labelsOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => (
      l10n.eventCardWarmAccept(_percent, _turns, EventRules.warmNoisePerTurn),
      l10n.eventCardWarmRefuse,
    ),
    RandomEventType.coldCurrent => (
      l10n.eventCardColdAccept(EventRules.heatingEnergyPerTurn, _turns),
      l10n.eventCardColdRefuse(_percent, _turns),
    ),
    RandomEventType.predators => (
      l10n.eventCardPredatorsAccept(
        player.eventState.predatorWave?.totalCount ?? 0,
      ),
      l10n.eventCardPredatorsRefuse(_bait()),
    ),
    RandomEventType.survivors => (_welcome(), l10n.eventCardRefuse),
    RandomEventType.caravan => (_trade(), l10n.eventCardRefuse),
    RandomEventType.storm || RandomEventType.wreck => null,
  };

  String _predatorsLine() {
    final wave = player.eventState.predatorWave;
    if (wave == null) return l10n.eventCardPredatorsWatching;
    final defenders =
        l10n.raidDefenders(RaidDueWarning.defenderCountOf(player));
    return l10n.eventCardPredatorsWave(wave.waveLabel(l10n), defenders);
  }

  int _bait() =>
      (player.resources[ResourceType.algae]?.amount ?? 0) *
      EventRules.baitAlgaePercent ~/
      100;

  String _welcome() {
    final int count = player.eventState.survivors ?? 0;
    return l10n.eventCardSurvivorsAccept(
      UnitType.harpoonist.units(l10n, count),
    );
  }

  String _trade() {
    final from = player.eventState.tradeFrom?.displayName(l10n) ?? '?';
    final to = player.eventState.tradeTo?.displayName(l10n) ?? '?';
    return l10n.eventCardTrade(
      EventRules.caravanGive,
      from,
      EventRules.caravanGet,
      to,
    );
  }

  int _wreckTurns() {
    final until = player.eventState.wreckUntilTurn;
    return until == null ? EventRules.wreckTurns : turnsLeft(until, game.turn);
  }
}
