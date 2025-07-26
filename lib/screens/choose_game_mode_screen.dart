import 'package:flutter/material.dart';
import 'package:geo_quiz_app/models/game_type.dart';
import 'guess_flag_screen.dart';
import 'guess_all_countries_screen.dart';  
import 'find_the_country_screen.dart';

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
        return 7;
      default:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLimit = getTimeLimitForRegion(region);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Game Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Game Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              if (gameType == GameType.guessFlag) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuessFlagScreen(
                          region: region,
                          isPractice: true,
                          timeLimitMinutes: timeLimit, gameType: GameType.guessFlag,
                        ),
                      ),
                    );
                  },
                  child: const Text('Practice Mode'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuessFlagScreen(
                          region: region,
                          isPractice: false,
                          timeLimitMinutes: timeLimit, gameType: GameType.guessFlag,
                        ),
                      ),
                    );
                  },
                  child: const Text('Timed Mode'),
                ),
              ] else if (gameType == GameType.guessAllCountries) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuessAllCountriesScreen(
                          region: region,
                          isPractice: true,
                          timeLimitMinutes: timeLimit, gameType: GameType.guessAllCountries,
                        ),
                      ),
                    );
                  },
                  child: const Text('Practice Mode'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuessAllCountriesScreen(
                          region: region,
                          isPractice: false,
                          timeLimitMinutes: timeLimit, gameType: GameType.guessAllCountries,
                        ),
                      ),
                    );
                  },
                  child: const Text('Timed Mode'),
                ),
              ] else if (gameType == GameType.findTheCountry) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FindTheCountryScreen(
                          region: region,
                          isPractice: true,
                          timeLimitMinutes: timeLimit, gameType: GameType.findTheCountry,
                        ),
                      ),
                    );
                  },
                  child: const Text('Practice Mode'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FindTheCountryScreen(
                          region: region,
                          isPractice: false,
                          timeLimitMinutes: timeLimit,
                          gameType: GameType.findTheCountry,
                        ),
                      ),
                    );
                  },
                  child: const Text('Timed Mode'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
