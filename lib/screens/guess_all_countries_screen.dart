import 'dart:async';
import 'package:flutter/material.dart';
import '../data/countries.dart'; 
import 'home_screen.dart';
import '../widgets/world_map_widgets.dart';
import '../models/game_type.dart';
import 'choose_region_screen.dart';

class GuessAllCountriesScreen extends StatefulWidget {
  final String region;
  final bool isPractice;
  final int timeLimitMinutes;
  final GameType gameType;

  const GuessAllCountriesScreen({
    super.key,
    required this.region,
    required this.isPractice,
    required this.timeLimitMinutes,
    required this.gameType,
  });

  @override
  State<GuessAllCountriesScreen> createState() => _GuessAllCountriesScreenState();
}

class _GuessAllCountriesScreenState extends State<GuessAllCountriesScreen> {
  late List<Map<String, String>> allCountries;
  final Set<String> guessedCountries = {};
  final TextEditingController _controller = TextEditingController();

  Timer? countdownTimer;
  late int secondsLeft;
  bool gameOver = false;
  String message = '';
  Color messageColor = Colors.red;

  String? currentHint; 

  @override
  void initState() {
    super.initState();
    _initGame();
    if (!widget.isPractice) {
      secondsLeft = widget.timeLimitMinutes * 60;
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsLeft == 0) {
          timer.cancel();
          setState(() {
            gameOver = true;
            message = 'Time\'s up!';
            messageColor = Colors.blue;
          });
        } else {
          setState(() {
            secondsLeft--;
          });
        }
      });
    }
  }

  void _initGame() {
    allCountries = widget.region == 'World'
        ? List.from(countries)
        : countries.where((c) => c['region'] == widget.region).toList();
    guessedCountries.clear();
    gameOver = false;
    message = '';
    messageColor = Colors.red;
    currentHint = null;
    _controller.clear();
  }

  void _showHint() {
    if (currentHint != null) return;
    final notGuessed = allCountries
        .map((c) => c['name']!)
        .where((name) => !guessedCountries.contains(name))
        .toList();

    if (notGuessed.isNotEmpty) {
      setState(() {
        currentHint = notGuessed.first; 
        message = 'Hint: $currentHint';
        messageColor = Colors.green;
      });
    }
  }

  void _checkAnswer(String input) {
    if (gameOver) return;

    final answer = input.trim().toLowerCase();

    final foundCountry = allCountries.firstWhere(
      (country) => country['name']!.toLowerCase() == answer,
      orElse: () => {},
    );

    if (foundCountry.isEmpty) return;

    final countryName = foundCountry['name']!;

    if (guessedCountries.contains(countryName)) return;

    setState(() {
      guessedCountries.add(countryName);
      _controller.clear();

      if (currentHint == countryName) {
        currentHint = null;
        message = '';
      }

      if (guessedCountries.length == allCountries.length) {
        gameOver = true;
        message = 'You guessed all countries!';
        messageColor = Colors.green;
        countdownTimer?.cancel();
      }
    });
  }

  void _restartGame() {
    setState(() {
      _controller.clear();
      guessedCountries.clear();
      allCountries = widget.region == 'World'
          ? List.from(countries)
          : countries.where((c) => c['region'] == widget.region).toList();
      gameOver = false;
      message = '';
      messageColor = Colors.red;
      currentHint = null;

      if (!widget.isPractice) {
        countdownTimer?.cancel();
        secondsLeft = widget.timeLimitMinutes * 60;
        countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (secondsLeft == 0) {
            timer.cancel();
            setState(() {
              gameOver = true;
              message = 'Time\'s up!';
              messageColor = Colors.blue;
            });
          } else {
            setState(() {
              secondsLeft--;
            });
          }
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/guess_all_countries.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(100)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Guess All Countries: ${widget.region}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            tooltip: 'Main Menu',
                            icon: const Icon(Icons.home, color: Colors.white),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: gameOver
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildGameOverUI(),
                            ),
                          )
                        : _buildGameUI(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameUI() {
    final total = allCountries.length;
    final guessed = guessedCountries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.isPractice)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Time Left: ${_formatTime(secondsLeft)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          'Guessed: $guessed / $total',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Type a country name',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white.withAlpha(30),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: _checkAnswer,
            enabled: !gameOver,
            cursorColor: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 24,
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: messageColor,
                shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: WorldMapScreen(
                  region: widget.region,
                  guessedCountries: guessedCountries,
                ),
              ),
              if (widget.isPractice)
                Positioned(
                  top: 10,
                  right: 10,
                  child: ElevatedButton.icon(
                    onPressed: _showHint,
                    icon: const Icon(Icons.visibility, color: Colors.greenAccent),
                    label: const Text(
                      'Hint',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(175),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverUI() {
    final total = allCountries.length;
    final guessed = guessedCountries.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Guessed $guessed / $total',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _restartGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(175),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Restart 🔁'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => ChooseRegionScreen(gameType: widget.gameType),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(175),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Change Region 🗺️'),
          ),
        ),
      ],
    );
  }
}
