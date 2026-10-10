import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_completion.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_end.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn/objective_turn_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _wreck = TemporaryObjective(
  kind: TemporaryObjectiveKind.wreck,
  title: "Fouille l'épave d'ici la fin du tour 17",
  lastTurn: 17,
);

const _predators = TemporaryObjective(
  kind: TemporaryObjectiveKind.predators,
  title: 'Repousse le banc de prédateurs',
  lastTurn: 12,
);

TurnResult _result({
  List<ObjectiveCompletion> objectives = const [],
  List<TemporaryObjectiveEnd> temporaryObjectives = const [],
}) => TurnResult(
  changes: const [],
  previousTurn: 3,
  newTurn: 4,
  hadRecruitedUnits: false,
  objectives: objectives,
  temporaryObjectives: temporaryObjectives,
);

/// A turn that completed objective [id], crediting [credited].
TurnResult _completed(ObjectiveId id, Map<ResourceType, int> credited) =>
    _result(
      objectives: [
        ObjectiveCompletion(
          objective: ObjectiveCatalog.byId(id),
          credited: credited,
        ),
      ],
    );

/// A turn that ended the temporary [objective] with [outcome].
TurnResult _ended(
  TemporaryObjective objective,
  TemporaryObjectiveOutcome outcome,
) => _result(
  temporaryObjectives: [
    TemporaryObjectiveEnd(objective: objective, outcome: outcome),
  ],
);

Future<void> _show(WidgetTester tester, TurnResult result) => tester.pumpWidget(
  MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(body: ObjectiveTurnSection(result: result)),
  ),
);

void main() {
  group('ObjectiveTurnSection', () {
    test('has content only with objectives completed or ended', () {
      bool hasContent(TurnResult result) =>
          ObjectiveTurnSection.hasContent(result);

      expect(hasContent(_result()), isFalse);
      expect(hasContent(_completed(ObjectiveId.hqLevel1, const {})), isTrue);
      expect(
        hasContent(_ended(_wreck, TemporaryObjectiveOutcome.done)),
        isTrue,
      );
    });

    testWidgets('a completed objective shows its credited reward', (
      tester,
    ) async {
      await _show(
        tester,
        _completed(ObjectiveId.hqLevel1, const {
          ResourceType.coral: 30,
          ResourceType.ore: 12,
        }),
      );

      expect(
        find.text(
          'Objectif accompli : Monte le QG au niveau 1 '
          '(+30 corail, +12 minerai)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a completion crediting nothing has no reward', (tester) async {
      await _show(tester, _completed(ObjectiveId.kernelLevel10, const {}));

      expect(
        find.text('Objectif accompli : Monte le Noyau au niveau 10'),
        findsOneWidget,
      );
    });

    testWidgets('a temporary objective done is accomplished', (tester) async {
      await _show(tester, _ended(_wreck, TemporaryObjectiveOutcome.done));

      expect(
        find.text(
          "Objectif accompli : Fouille l'épave d'ici la fin du tour 17",
        ),
        findsOneWidget,
      );
    });

    testWidgets('a temporary objective expired is struck through', (
      tester,
    ) async {
      const line = "Fouille l'épave d'ici la fin du tour 17 (raté)";
      await _show(tester, _ended(_wreck, TemporaryObjectiveOutcome.expired));

      final text = tester.widget<Text>(find.text(line)).textSpan as TextSpan;
      final [title, missed] = text.children!.cast<TextSpan>();
      expect(title.style?.decoration, TextDecoration.lineThrough);
      expect(missed.style?.decoration, isNull);
    });

    testWidgets('a temporary objective failed is struck through', (
      tester,
    ) async {
      await _show(tester, _ended(_predators, TemporaryObjectiveOutcome.failed));

      expect(
        find.text('Repousse le banc de prédateurs (raté)'),
        findsOneWidget,
      );
    });
  });
}
