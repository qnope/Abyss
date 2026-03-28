import 'package:flutter/material.dart';
import 'presentation/theme/abyss_theme.dart';

void main() {
  runApp(const AbyssApp());
}

class AbyssApp extends StatelessWidget {
  const AbyssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABYSSES',
      theme: AbyssTheme.create(),
      home: const Scaffold(
        body: Center(
          child: Text('ABYSSES'),
        ),
      ),
    );
  }
}
