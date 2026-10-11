import 'package:flutter/widgets.dart';

import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_status.dart';
import '../../../domain/objective/objective_migration.dart';
import '../../../domain/objective/tip/tip_catalog.dart';
import 'tip_stack.dart';

/// Opens the « première fois » tips of the human player of [game], all
/// the unseen ones whose situation is there stacked in one dialog: they
/// are saved as seen through [repository] before it shows.
class TipPresenter {
  final Game game;
  final GameRepository repository;

  TipPresenter({required this.game, required this.repository});

  bool _showing = false;

  /// Opens the stack of the tips waiting, if any; completes once it is
  /// closed. Does nothing while a stack is open, when the tips are off
  /// or once the game is over (won or lost, unless the play goes on
  /// after the victory).
  Future<void> showNext(BuildContext context) async {
    if (_showing || !_inPlay) return;
    final player = game.humanPlayer;
    final tips = TipCatalog.pendingFor(game, player);
    if (tips.isEmpty) return;
    _showing = true;
    try {
      final state = ObjectiveMigration.stateOf(game, player);
      for (final tip in tips) {
        state.markSeen(tip.id);
      }
      await repository.save(game);
      if (context.mounted) await showTipStack(context, tips);
    } finally {
      _showing = false;
    }
  }

  bool get _inPlay =>
      game.status == GameStatus.playing || game.status == GameStatus.freePlay;

  /// Opens the next tip once the frame after a player's action is drawn,
  /// unless another page, sheet or dialog (a fight, a report) covers the
  /// screen of [context] by then.
  void showAfterAction(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      showNext(context);
    });
  }
}
