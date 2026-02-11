import 'package:flutter/material.dart';

import 'navigation/main_navigation.dart';

class AbyssesApp extends StatelessWidget {
  const AbyssesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABYSSES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1F3C),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF132240),
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D1F3C),
          selectedItemColor: Color(0xFF64B5F6),
          unselectedItemColor: Color(0xFF546E7A),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF26C6DA),
          surface: Color(0xFF132240),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
