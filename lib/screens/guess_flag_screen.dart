import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geo_quiz_app/screens/home_screen.dart';
import '../data/countries.dart';
import '../models/game_type.dart';
import 'choose_region_screen.dart';

class GuessFlagScreen extends StatefulWidget {
  final String region;
  final bool isPractice;
  final int timeLimitMinutes;
  final GameType gameType;

  const GuessFlagScreen({
    super.key,
    required this.region,
    required this.isPractice,
    required this.timeLimitMinutes,
    required this.gameType,
  });

  @override
  State<GuessFlagScreen> createState() => _GuessFlagScreenState();
}

class _GuessFlagScreenState extends State<GuessFlagScreen> {
  late List<Map<String, String>> remainingCountries;
  late List<Map<String, String>> skippedCountries = [];
  late Map<String, String> currentCountry;
  final TextEditingController _controller = TextEditingController();
  String message = '';
  Color messageColor = Colors.red;

  Timer? countdownTimer;
  late int secondsLeft;
  late int totalCountries;
  int correctCount = 0;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _initCountryPool();
    _pickRandomCountry();

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

  @override
  void dispose() {
    countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _initCountryPool() {
    setState(() {
      if (widget.region == 'World') {
        remainingCountries = List.from(countries);
      } else {
        remainingCountries =
            countries.where((c) => c['region'] == widget.region).toList();
      }
      skippedCountries.clear();
      correctCount = 0;
      gameOver = false;
      message = '';
      totalCountries = remainingCountries.length;
    });
  }

  void _pickRandomCountry() {
    setState(() {
      if (remainingCountries.isEmpty) {
        if (skippedCountries.isEmpty) {
          _endGame();
          return;
        } else {
          remainingCountries = List.from(skippedCountries);
          skippedCountries.clear();
        }
      }
      final random = Random();
      final index = random.nextInt(remainingCountries.length);
      currentCountry = remainingCountries[index];
      _controller.clear();
      message = '';
    });
  }

  void _endGame() {
    if (!gameOver) {
      if (!widget.isPractice) countdownTimer?.cancel();
      setState(() {
        gameOver = true;
        message = 'You guessed all flags!';
        messageColor = Colors.blue;
      });
    }
  }

  void _removeCurrentCountry() {
    remainingCountries
        .removeWhere((country) => country['name'] == currentCountry['name']);
  }

  void _checkAnswer(String answer) {
    if (gameOver) return;
    final cleanedAnswer = answer.trim().toLowerCase();
    final correct = currentCountry['name']!.toLowerCase();
    if (cleanedAnswer == correct) {
      setState(() {
        message = 'Correct! 🎉';
        messageColor = Colors.green;
        correctCount++;
      });
      Timer(const Duration(seconds: 1), () {
        _removeCurrentCountry();
        setState(() {
          _pickRandomCountry();
        });
      });
    }
  }

  void _skipFlag() {
    if (gameOver) return;
    setState(() {
      skippedCountries.add(currentCountry);
      remainingCountries
          .removeWhere((country) => country['name'] == currentCountry['name']);
      _pickRandomCountry();
    });
  }

  void _restartGame() {
    if (!widget.isPractice) {
      secondsLeft = widget.timeLimitMinutes * 60;
      countdownTimer?.cancel();
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
    _initCountryPool();
    _pickRandomCountry();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/guess_the_flag.jpg',
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
                      Text(
                        'Guess the Flag: ${widget.region}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1))],
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: gameOver || remainingCountries.isEmpty
                          ? _buildGameOverUI()
                          : _buildGameUI(),
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

  Widget _buildGameUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isPractice)
          Text(
            'Time Left: ${_formatTime(secondsLeft)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '$correctCount / $totalCountries',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 250,
          height: 150,
          child: Image.asset(
            'icons/flags/png/${currentCountry['code']}.png',
            package: 'country_icons',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Type the country name',
            labelStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          onChanged: _checkAnswer,
          enabled: !gameOver,
        ),
        const SizedBox(height: 12),
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
        if (widget.isPractice)
          TextButton.icon(
            onPressed: () {
              setState(() {
                message = 'Answer: ${currentCountry['name']}';
                messageColor = Colors.greenAccent;
              });
            },
            icon: const Icon(Icons.visibility, color: Colors.greenAccent),
            label: const Text(
              'Reveal Answer',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        TextButton.icon(
          onPressed: _skipFlag,
          icon: const Icon(Icons.skip_next_rounded, color: Colors.orangeAccent),
          label: const Text(
            'Skip',
            style: TextStyle(color: Colors.orangeAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          ' Guessed $correctCount / $totalCountries',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(175),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              _restartGame();
            },
            child: const Text('Restart 🔁'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(175),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ChooseRegionScreen(gameType: widget.gameType),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            },
            child: const Text('Change Region 🗺️'),
          ),
        ),
      ],
    );
  }
}
