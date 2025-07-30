import 'package:flutter/material.dart';
import 'package:geo_quiz_app/models/game_type.dart';
import 'guess_flag_screen.dart';
import 'guess_all_countries_screen.dart';
import 'find_the_country_screen.dart';
import 'guess_the_capital.dart';
import 'find_the_capital_screen.dart';
import 'home_screen.dart';

class ChooseGameModeScreen extends StatelessWidget {
  final String region;
  final GameType gameType;

  const ChooseGameModeScreen({
    super.key,
    required this.region,
    required this.gameType,
  });

  int getTimeLimitForRegion(String region) {
    switch (region) {
      case 'World':
        return 25;
      case 'Oceania':
        return 5;
      default:
        return 15;
    }
  }

  String getDescription() {
    return 'Practice mode is untimed and provides hints to help you learn.\n'
        'Timed mode challenges you against the clock for a more intense experience.';
  }

  @override
  Widget build(BuildContext context) {
    final timeLimit = getTimeLimitForRegion(region);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/choose_game_mode.jpg',  
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(100), 
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  const Text(
                    'Choose Game Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black87, offset: Offset(1,1))],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getDescription(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildModeButton(
                          context,
                          label: 'Practice Mode 📝',
                          onPressed: () {
                            _navigateToGameScreen(context, isPractice: true, timeLimit: timeLimit);
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildModeButton(
                          context,
                          label: 'Timed Mode ⏳',
                          onPressed: () {
                            _navigateToGameScreen(context, isPractice: false, timeLimit: timeLimit);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  tooltip: 'Main Menu',
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context,
    {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withAlpha(175), 
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _navigateToGameScreen(BuildContext context,
      {required bool isPractice, required int timeLimit}) {
    Widget screen;

    switch (gameType) {
      case GameType.guessFlag:
        screen = GuessFlagScreen(
          region: region,
          isPractice: isPractice,
          timeLimitMinutes: timeLimit,
          gameType: GameType.guessFlag,
        );
        break;
      case GameType.guessAllCountries:
        screen = GuessAllCountriesScreen(
          region: region,
          isPractice: isPractice,
          timeLimitMinutes: timeLimit,
          gameType: GameType.guessAllCountries,
        );
        break;
      case GameType.findTheCountry:
        screen = FindTheCountryScreen(
          region: region,
          isPractice: isPractice,
          timeLimitMinutes: timeLimit,
          gameType: GameType.findTheCountry,
        );
        break;
      case GameType.guessTheCapital:
        screen = GuessCapitalScreen(
          region: region,
          isPractice: isPractice,
          timeLimitMinutes: timeLimit,
          gameType: GameType.guessTheCapital,
        );
        break;
      case GameType.findTheCapital:
        screen = FindTheCapitalScreen(
          region: region,
          isPractice: isPractice,
          timeLimitMinutes: timeLimit,
          gameType: GameType.findTheCapital,
        );
        break;
    }

   Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}