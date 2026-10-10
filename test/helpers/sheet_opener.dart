import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'localized_app.dart';

/// Opens the bottom sheet [show] puts up, with the texts of [locale].
Future<void> openSheet(
  WidgetTester tester,
  Locale locale,
  void Function(BuildContext context) show,
) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(localizedApp(
    locale: locale,
    Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => show(context),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
