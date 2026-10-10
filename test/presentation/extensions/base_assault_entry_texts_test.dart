import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/presentation/extensions/action_failure_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_texts.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/history_entry_samples.dart';
import '../../helpers/l10n_fixtures.dart';

BaseAssaultEntry _entry({required bool victory, required bool defending}) =>
    baseAssaultEntry(victory: victory, defending: defending);

void main() {
  test('titles the four ways an assault reads, in each language', () {
    expect(
      _entry(victory: true, defending: false).displayTitle(en),
      'Assault on Nacre succeeded',
    );
    expect(
      _entry(victory: false, defending: false).displayTitle(en),
      'Assault repelled by Nacre',
    );
    expect(
      _entry(victory: true, defending: true).displayTitle(fr),
      'Base attaquée par Nacre',
    );
    expect(
      _entry(victory: false, defending: true).displayTitle(es),
      'Asalto de Nacre rechazado',
    );
  });

  test('glows green for a side that won, red for one that lost', () {
    final theme = AbyssTheme.create();

    expect(
      _entry(victory: true, defending: false).accentColor(theme),
      AbyssColors.success,
    );
    expect(
      _entry(victory: true, defending: true).accentColor(theme),
      theme.colorScheme.error,
    );
    expect(
      _entry(victory: false, defending: true).accentColor(theme),
      AbyssColors.success,
    );
  });

  test('has a category of its own, named in each language', () {
    expect(HistoryEntryCategory.assault.label(fr), 'Assaut');
    expect(HistoryEntryCategory.assault.label(en), 'Assault');
    expect(HistoryEntryCategory.assault.label(es), 'Asalto');
  });

  test('tells why an attack on a base is refused', () {
    expect(
      ActionFailure.cannotAttackSelf.message(en),
      'You cannot attack yourself',
    );
    expect(ActionFailure.attackTooEarly.message(fr).isNotEmpty, isTrue);
    expect(ActionFailure.playerFallen.message(es), 'Esa base ha caído');
    expect(ActionFailure.noSuchPlayer.message(en), 'Player not found');
    expect(ActionFailure.baseNotRevealed.message(en).isNotEmpty, isTrue);
  });
}
