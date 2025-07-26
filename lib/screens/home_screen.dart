import 'package:flutter/material.dart';
import 'package:geo_quiz_app/screens/choose_region_screen.dart';
import 'package:geo_quiz_app/models/game_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geo Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Game Mode:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (_) => ChooseRegionScreen(gameType: GameType.guessFlag)),
                );
              },
              child: const Text('Guess the Flag 🌍'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (_) => ChooseRegionScreen(gameType: GameType.guessAllCountries)),
                );
              },
              child: const Text('Guess all Countries 🌍'),
            ),
             ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (_) => ChooseRegionScreen(gameType: GameType.guessTheCapital)),
                );
              },
              child: const Text('Guess the Capital 🌍'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChooseRegionScreen(gameType: GameType.findTheCountry),
                  ),
                );
              },
              child: const Text('Find the Country 🌍'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Find the Capital 🌍'),
            ),
          ],
        ),
      ),
    );
  }
}
