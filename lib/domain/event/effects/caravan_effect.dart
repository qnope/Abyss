import 'dart:math';

import '../../action/action_failure.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../resource/resource.dart';
import '../../resource/resource_type.dart';
import '../event_rules.dart';
import 'event_effect.dart';

/// Turtle caravan, which takes [EventRules.caravanGive] of the most
/// abundant resource for [EventRules.caravanGet] of the scarcest, both
/// picked among [traded] at the draw.
class CaravanEffect extends EventEffect {
  const CaravanEffect();

  /// Resources the caravan trades, in the order that breaks the ties.
  static const List<ResourceType> traded = <ResourceType>[
    ResourceType.algae,
    ResourceType.coral,
    ResourceType.ore,
  ];

  /// The most abundant of [traded], the first one on a tie.
  static ResourceType mostAbundant(Player player) => _pick(player, 1);

  /// The scarcest of [traded], the first one on a tie.
  static ResourceType scarcest(Player player) => _pick(player, -1);

  /// Only when the most abundant stock can pay and differs from the
  /// scarcest.
  @override
  bool allowedAt(Game game, Player player, int endedTurn) {
    final ResourceType from = mostAbundant(player);
    return _amount(player, from) >= EventRules.caravanGive &&
        from != scarcest(player);
  }

  @override
  void onDraw(
    Game game,
    Player player, {
    required int turn,
    required Random random,
  }) {
    player.eventState
      ..tradeFrom = mostAbundant(player)
      ..tradeTo = scarcest(player);
  }

  @override
  ActionFailure? refusal(Game game, Player player) {
    final ResourceType? from = player.eventState.tradeFrom;
    if (from == null || _amount(player, from) >= EventRules.caravanGive) {
      return null;
    }
    return ActionFailure.notEnoughStockToTrade;
  }

  /// Trading hands the stock over and fills the scarce one up to its cap.
  @override
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {
    final ResourceType? from = player.eventState.tradeFrom;
    final ResourceType? to = player.eventState.tradeTo;
    if (!accept || from == null || to == null) return;
    if (refusal(game, player) != null) return;
    player.resources[from]!.amount -= EventRules.caravanGive;
    final Resource gained = player.resources[to]!;
    gained.amount = min(
      gained.maxStorage,
      gained.amount + EventRules.caravanGet,
    );
  }

  static int _amount(Player player, ResourceType type) =>
      player.resources[type]?.amount ?? 0;

  /// First of [traded] whose amount, times [sign], is the greatest.
  static ResourceType _pick(Player player, int sign) {
    ResourceType best = traded.first;
    for (final ResourceType type in traded.skip(1)) {
      if (sign * _amount(player, type) > sign * _amount(player, best)) {
        best = type;
      }
    }
    return best;
  }
}
