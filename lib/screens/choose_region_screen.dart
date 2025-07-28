import 'package:flutter/material.dart';
import 'choose_game_mode_screen.dart';
import 'package:geo_quiz_app/models/game_type.dart';
import 'home_screen.dart'; 

class ChooseRegionScreen extends StatelessWidget {
  final GameType gameType;

  const ChooseRegionScreen({super.key, required this.gameType});

  List<String> get regions => const [
        'World',
        'Europe',
        'Asia',
        'Africa',
        'America',
        'Oceania',
      ];

  String getDescription() {
    switch (gameType) {
      case GameType.guessFlag:
        return 'You will see a flag from the selected region. Guess the correct country name.';
      case GameType.guessAllCountries:
        return 'Type all the country names from the region you selected.';
      case GameType.guessTheCapital:
        return 'You will see the flag, country, and region name (only for World). Type the capital city.';
      case GameType.findTheCountry:
        return 'You will get the name of a country from the selected region and must tap it on the map.';
      case GameType.findTheCapital:
        return 'You will get the name of a capital from the selected region and must tap it on the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  const Text(
                    'Choose Region',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getDescription(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView.builder(
                      itemCount: regions.length,
                      itemBuilder: (context, index) {
                        final region = regions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChooseGameModeScreen(
                                      region: region,
                                      gameType: gameType,
                                    ),
                                  ),
                                );
                              },
                              child: Text(region),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    tooltip: 'Main Menu',
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
