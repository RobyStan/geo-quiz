import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GeoQuizApp());
}

class GeoQuizApp extends StatelessWidget {
  const GeoQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Quiz',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
