import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/cheat_codes.dart';
import '../../../domain/game/difficulty.dart';
import '../../../domain/game/game_factory.dart';
import '../../../domain/objective/tutorial_offer.dart';
import '../../widgets/common/difficulty_picker.dart';
import '../../widgets/common/labeled_switch.dart';
import '../game/game_screen.dart';

class NewGameScreen extends StatefulWidget {
  final GameRepository repository;

  const NewGameScreen({super.key, required this.repository});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Difficulty _difficulty = Difficulty.normal;
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

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Partie')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entrez votre nom',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Nom du joueur',
                    prefixIcon: Icon(Icons.person),
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
                LabeledSwitch(
                  title: 'Tutoriel',
                  subtitle: 'Un guide t\'accompagne sur les premiers tours',
                  value: _tutorial,
                  onChanged: (on) => setState(() => _tutorial = on),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Commencer'),
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
      return 'Veuillez entrer un nom';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _controller.text.trim();
    final game = GameFactory.newSinglePlayer(
      playerName: name,
      difficulty: _difficulty,
      tutorial: _tutorial,
    );
    CheatCodes.apply(game.humanPlayer);
    await widget.repository.save(game);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          game: game,
          repository: widget.repository,
        ),
      ),
      (_) => false,
    );
  }
}
