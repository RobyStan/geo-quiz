import 'dart:async';
import 'package:flutter/material.dart';
import '../data/countries_test.dart'; 
//import '../data/countries.dart'; 
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
    if (currentHint != null) {
      return;
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guess All Countries: ${widget.region}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
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
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: gameOver ? _buildGameOverUI() : _buildGameUI(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameUI() {
    final total = allCountries.length;
    final guessed = guessedCountries.length;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isPractice)
            Text(
              'Time Left: ${_formatTime(secondsLeft)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 10),
          Text(
            'Guessed: $guessed / $total',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Type a country name',
              border: OutlineInputBorder(),
            ),
            onChanged: _checkAnswer,
            enabled: !gameOver,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 24,
            child: Center(
              child: Text(
                message,
                style: TextStyle(fontSize: 18, color: messageColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                WorldMapScreen(
                  region: widget.region,
                  guessedCountries: guessedCountries,
                ),
                if (widget.isPractice)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ElevatedButton.icon(
                      onPressed: _showHint,
                      icon: const Icon(Icons.lightbulb),
                      label: const Text('Hint'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Guessed $guessed / $total',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _restartGame,
            child: const Text('Restart'),
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
            child: const Text('Change Region'),
          ),
        ),
      ],
    );
  }
}