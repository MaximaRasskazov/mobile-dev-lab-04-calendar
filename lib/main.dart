import 'package:flutter/material.dart';

import 'pages/calendar_screen.dart';

void main() {
  runApp(const CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Календарь',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1B1C1F),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF202124)),
        cardTheme: const CardThemeData(color: Color(0xFF292A2D)),
      ),
      home: const CalendarScreen(),
    );
  }
}
