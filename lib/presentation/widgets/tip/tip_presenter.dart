import 'package:flutter/widgets.dart';

import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_status.dart';
import '../../../domain/objective/objective_migration.dart';
import '../../../domain/objective/tip/tip_catalog.dart';
import 'tip_card.dart';

/// Opens the « première fois » tips of the human player of [game], one at
/// a time: the first unseen one whose situation is there, saved as seen
/// through [repository] before it shows. The others wait for the next
/// opportunity.
class TipPresenter {
  final Game game;
  final GameRepository repository;

  TipPresenter({required this.game, required this.repository});

  bool _showing = false;

  /// Opens the next tip, if any; completes once it is closed. Does
  /// nothing while a tip is open, when the tips are off or once the game
  /// is over.
  Future<void> showNext(BuildContext context) async {
    if (_showing || game.status != GameStatus.playing) return;
    final player = game.humanPlayer;
    final tip = TipCatalog.nextFor(game, player);
    if (tip == null) return;
    _showing = true;
    try {
      ObjectiveMigration.stateOf(game, player).markSeen(tip.id);
      await repository.save(game);
      if (context.mounted) await showTipCard(context, tip);
    } finally {
      _showing = false;
    }
  }

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
