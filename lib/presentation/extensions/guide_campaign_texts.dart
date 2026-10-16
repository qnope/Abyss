import '../../domain/fight/assault/assault_rehearsals.dart';
import '../../domain/map/transition_base_type.dart';
import '../../domain/objective/guide/guide_message.dart';
import '../l10n/app_localizations.dart';

/// What the guide says past the tutorial chapter, in the player's
/// language: the assaults, the passages, the posts held and the kernel.
extension GuideCampaignText on GuideMessage {
  /// The words of a message of the campaign, empty for any other.
  String campaignText(AppLocalizations l10n) => switch (this) {
    GuideAdmiralNeedsBarracks(:final target, :final barracksLevel) => l10n
        .guideAdmiralNeedsBarracks(target.name, barracksLevel),
    GuideAdmiralToRecruit(:final target) => l10n.guideAdmiralToRecruit(
      target.name,
    ),
    GuideAdmiralToSend(:final target, :final level, :final from) => l10n
        .guideAdmiralToSend(target.name, level, from, _passageOn(from)),
    GuidePostToFind(:final target) => l10n.guidePostToFind(target.name),
    final GuidePostAssault assault => assault._text(l10n),
    GuideAdmiralFell(:final target) => l10n.guideAdmiralFell(target.name),
    GuidePassageNeedsHq(:final passage, :final headquarters) => l10n
        .guidePassageNeedsHq(passage.name, headquarters),
    GuidePostUndefended(:final type, :final level) => l10n.guidePostUndefended(
      type.name,
      level,
    ),
    GuideKernelWave(:final monsters, :final needed) =>
      needed == null
          ? l10n.guideKernelWaveAll(monsters)
          : l10n.guideKernelWaveNeeded(needed),
    GuideLeviathanReturn(:final level, :final missing) =>
      missing == 0
          ? l10n.guideLeviathanReturn(level)
          : '${l10n.guideLeviathanReturn(level)} '
                '${l10n.guideLeviathanReinforce(missing)}',
    _ => '',
  };

  /// The post a level opens downwards by: the Faille, then the Cheminée.
  static String _passageOn(int level) => level == 1
      ? TransitionBaseType.faille.name
      : TransitionBaseType.cheminee.name;
}

extension on GuidePostAssault {
  /// The target, then the army to send when one would do.
  String _text(AppLocalizations l10n) {
    final String intro = l10n.guidePostAssault(target.name);
    final int? count = harpoonists;
    if (count == null) return intro;
    final planner = AssaultRehearsals.planner;
    final int wins = (planner.confidence * planner.rehearsals).round();
    final String army = l10n.guidePostAssaultArmy(
      count,
      wins,
      planner.rehearsals,
    );
    return '$intro $army';
  }
}
