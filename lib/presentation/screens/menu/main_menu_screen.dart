import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/save_sections.dart';
import '../../../domain/game/save_summary.dart';
import '../../extensions/save_summary_extensions.dart';
import '../../widgets/backdrop/abyss_backdrop.dart';
import '../../widgets/menu/beta_notice.dart';
import '../../widgets/menu/glow_title.dart';
import '../../widgets/menu/menu_button.dart';
import '../../widgets/menu/menu_layout.dart';
import '../../widgets/menu/menu_settings_button.dart';
import '../game/resume_game.dart';
import 'load_game_screen.dart';
import 'new_game_screen.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/language_scope.dart';

/// The home screen: the colony in the abyss, a shortcut to continue the
/// latest game in progress, a new game and the saved games, with the
/// language settings in a corner when the app has a [LanguageScope].
class MainMenuScreen extends StatefulWidget {
  final GameRepository repository;

  const MainMenuScreen({super.key, required this.repository});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late SaveSections _saves = _readSaves();

  SaveSections _readSaves() => SaveSections.of(widget.repository.loadAll());

  @override
  Widget build(BuildContext context) {
    final resumable = _saves.mostRecentInProgress;
    final l10n = context.l10n;
    final language = LanguageScope.maybeOf(context);
    return Scaffold(
      body: AbyssBackdrop(
        child: MenuLayout(
          header: GlowTitle(title: 'ABYSSES', subtitle: l10n.menuSubtitle),
          actions: [
            if (resumable != null)
              MenuButton(
                label: l10n.menuContinue,
                subtitle: SaveSummary.of(resumable).resumeLabel(l10n),
                onPressed:
                    () => resumeGame(context, resumable, widget.repository),
              ),
            MenuButton(
              label: l10n.menuNewGame,
              variant:
                  resumable == null
                      ? MenuButtonVariant.primary
                      : MenuButtonVariant.outlined,
              onPressed:
                  () => _open(NewGameScreen(repository: widget.repository)),
            ),
            MenuButton(
              label: l10n.menuLoadGame,
              variant: MenuButtonVariant.outlined,
              badgeCount: _saves.count,
              onPressed:
                  () => _open(LoadGameScreen(repository: widget.repository)),
            ),
          ],
          footer: const BetaNotice(),
          corner:
              language == null ? null : MenuSettingsButton(settings: language),
        ),
      ),
    );
  }

  /// Opens [screen], then reads the saves again: games may have been
  /// deleted or created there.
  Future<void> _open(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    if (mounted) setState(() => _saves = _readSaves());
  }
}
