import 'package:flutter/material.dart';
import 'package:geo_quiz_app/screens/choose_region_screen.dart';
import 'package:geo_quiz_app/models/game_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_screen.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Geo Quiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                      shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1,1))],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuButton(
                            context,
                            label: 'Guess the Flag 🎏',
                            gameType: GameType.guessFlag,
                          ),
                          _buildMenuButton(
                            context,
                            label: 'Guess all Countries 🌍',
                            gameType: GameType.guessAllCountries,
                          ),
                          _buildMenuButton(
                            context,
                            label: 'Guess the Capital 🏛️',
                            gameType: GameType.guessTheCapital,
                          ),
                          _buildMenuButton(
                            context,
                            label: 'Find the Country 🔍',
                            gameType: GameType.findTheCountry,
                          ),
                          _buildMenuButton(
                            context,
                            label: 'Find the Capital 🔎',
                            gameType: GameType.findTheCapital,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String label, required GameType gameType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(175), 
            foregroundColor: Colors.black87, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChooseRegionScreen(gameType: gameType),
              ),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }
}
