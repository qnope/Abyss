import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/opening/story_page.dart';
import 'package:abyss/presentation/widgets/opening/story_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pages = [
  StoryPage(picture: SizedBox(), title: 'One', lines: ['1a', '1b']),
  StoryPage(picture: SizedBox(), title: 'Two', lines: ['2a', '2b']),
  StoryPage(picture: SizedBox(), title: 'Three', lines: ['3a', '3b']),
];

void main() {
  late int done;

  setUp(() => done = 0);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Center(
            child: StoryPager(
              pages: _pages,
              doneLabel: 'Go',
              onDone: () => done++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the first page, its title and its lines', (tester) async {
    await pump(tester);

    expect(find.text('One'), findsOneWidget);
    expect(find.text('1a'), findsOneWidget);
    expect(find.text('1b'), findsOneWidget);
    expect(find.text('Two'), findsNothing);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('« Suivant » turns the pages up to the last one', (tester) async {
    await pump(tester);

    await tap(tester, 'Suivant');
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('One'), findsNothing);
    await tap(tester, 'Suivant');

    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Suivant'), findsNothing);
    expect(find.text('Passer'), findsNothing);
    expect(done, 0);
  });

  testWidgets('the button of the last page ends the story once', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Suivant');
    await tap(tester, 'Suivant');

    await tap(tester, 'Go');
    await tap(tester, 'Go');

    expect(done, 1);
  });

  testWidgets('« Passer » ends the story at once', (tester) async {
    await pump(tester);

    await tap(tester, 'Passer');

    expect(done, 1);
  });

  testWidgets('a swipe turns the pages both ways', (tester) async {
    await pump(tester);

    await tester.fling(find.text('One'), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);

    await tester.fling(find.text('Two'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
  });
}
