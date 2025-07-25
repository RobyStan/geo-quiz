import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geo_quiz_app/screens/home_screen.dart';
import '../data/countries_test.dart';

class GuessFlagScreen extends StatefulWidget {
  final String region;
  final bool isPractice;
  final int timeLimitMinutes;

  const GuessFlagScreen({
    super.key,
    required this.region,
    required this.isPractice,
    required this.timeLimitMinutes,
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
  late  int totalCountries;
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
        remainingCountries = countries.where((c) => c['region'] == widget.region).toList();
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
        message = 'Game Over!';
        messageColor = Colors.blue;
      });
    }
  }

  void _removeCurrentCountry() {
    remainingCountries.removeWhere((country) => country['name'] == currentCountry['name']);
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
      remainingCountries.removeWhere((country) => country['name'] == currentCountry['name']);
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
      appBar: AppBar(title: Text('Guess the Flag: ${widget.region}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: gameOver || remainingCountries.isEmpty
              ? _buildGameOverUI()
              : _buildGameUI(),
        ),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        Text(
          '$correctCount / $totalCountries',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Image.asset(
          'icons/flags/png/${currentCountry['code']}.png',
          package: 'country_icons',
          width: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Type the country name',
            border: OutlineInputBorder(),
          ),
          onChanged: _checkAnswer,
          enabled: !gameOver,
        ),
        const SizedBox(height: 12),
        if (message.isNotEmpty)
          Text(
            message,
            style: TextStyle(fontSize: 18, color: messageColor),
          ),
        const SizedBox(height: 20),
        if (widget.isPractice)
          TextButton(
            onPressed: () {
              setState(() {
                message = 'Answer: ${currentCountry['name']}';
                messageColor = Colors.green;
              });
            },
            child: const Text('Reveal Answer'),
          ),
        TextButton(
          onPressed: _skipFlag,
          child: const Text('Skip'),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          ' Guessed $correctCount / $totalCountries',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _restartGame();
          },
          child: const Text('Restart'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ); 
          },
          child: const Text('Main Menu'),
        ),
      ],
    );
  }
}
