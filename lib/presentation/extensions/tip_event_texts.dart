import '../../domain/event/event_rules.dart';
import '../../domain/event/random_event_type.dart';
import '../l10n/app_localizations.dart';
import 'random_event_type_extensions.dart';
import 'tip_text.dart';

/// The tip of the random events' principle.
TipText eventsTip(AppLocalizations l10n) => (
  title: l10n.tipEventsTitle,
  lines: [
    l10n.tipEventsLine1(EventRules.minGap, EventRules.maxGap),
    l10n.tipEventsLine2,
    l10n.tipEventsLine3,
  ],
);

/// The tip of the event [type], titled after it.
TipText eventTip(RandomEventType type, AppLocalizations l10n) => (
  title: type.label(l10n),
  lines: switch (type) {
    RandomEventType.warmCurrent => [
      l10n.tipWarmCurrentLine1(EventRules.effectTurns),
      l10n.tipWarmCurrentLine2,
      l10n.tipWarmCurrentLine3,
    ],
    RandomEventType.wreck => [
      l10n.tipWreckLine1(EventRules.wreckTurns),
      l10n.tipWreckLine2,
      l10n.tipWreckLine3(EventRules.wreckNoise),
    ],
    RandomEventType.predators => [
      l10n.tipPredatorsLine1,
      l10n.tipPredatorsLine2,
      l10n.tipPredatorsLine3,
    ],
    RandomEventType.storm => [
      l10n.tipStormLine1(EventRules.stormTurns),
      l10n.tipStormLine2(EventRules.stormNoiseRelief),
    ],
    RandomEventType.survivors => [
      l10n.tipSurvivorsLine1,
      l10n.tipSurvivorsLine2,
      l10n.tipSurvivorsLine3,
    ],
    RandomEventType.caravan => [l10n.tipCaravanLine1, l10n.tipCaravanLine2],
    RandomEventType.coldCurrent => [
      l10n.tipColdCurrentLine1(EventRules.effectTurns),
      l10n.tipColdCurrentLine2,
      l10n.tipColdCurrentLine3,
    ],
  },
);
