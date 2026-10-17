import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/cheat_codes.dart';
import '../../../domain/game/difficulty.dart';
import '../../../domain/game/game_factory.dart';
import '../../../domain/objective/tutorial_offer.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/common/difficulty_picker.dart';
import '../../widgets/common/faction_count_picker.dart';
import '../../widgets/common/labeled_switch.dart';
import '../game/game_screen.dart';
import 'opening_story_screen.dart';

class NewGameScreen extends StatefulWidget {
  final GameRepository repository;

  const NewGameScreen({super.key, required this.repository});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  static const _minNameLength = 2;
  static const _defaultFactions = 3;

  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Difficulty _difficulty = Difficulty.normal;
  int _factions = _defaultFactions;
  late bool _tutorial = TutorialOffer.checkedByDefault(
    widget.repository.loadAll(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGameTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.newGameEnterName, style: textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: l10n.newGameNameHint,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: _validateName,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                DifficultyPicker(
                  current: _difficulty,
                  onChanged: (d) => setState(() => _difficulty = d),
                ),
                const SizedBox(height: 16),
                FactionCountPicker(
                  count: _factions,
                  onChanged: (n) => setState(() => _factions = n),
                ),
                const SizedBox(height: 16),
                LabeledSwitch(
                  title: l10n.newGameTutorial,
                  subtitle: l10n.newGameTutorialHint,
                  value: _tutorial,
                  onChanged: (on) => setState(() => _tutorial = on),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(l10n.newGameStart),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.newGameNameEmpty;
    }
    if (value.trim().length < _minNameLength) {
      return context.l10n.newGameNameTooShort(_minNameLength);
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _controller.text.trim();
    final game = GameFactory.newGame(
      playerName: name,
      difficulty: _difficulty,
      tutorial: _tutorial,
      factionCount: _factions,
    );
    CheatCodes.apply(game.humanPlayer);
    await widget.repository.save(game);

    if (!mounted) return;

    startWithOpeningStory(
      Navigator.of(context),
      (_) => GameScreen(game: game, repository: widget.repository),
    );
  }
}
