import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/world_map_find_country.dart';
import 'home_screen.dart';
import 'choose_region_screen.dart';
import '../models/game_type.dart';
import '../data/countries_test.dart';

class FindTheCountryScreen extends StatefulWidget {
  final String region;
  final bool isPractice;
  final int timeLimitMinutes;
  final GameType gameType;

  const FindTheCountryScreen({
    super.key,
    required this.region,
    required this.isPractice,
    required this.timeLimitMinutes,
    required this.gameType,
  });

  @override
  State<FindTheCountryScreen> createState() => _FindTheCountryScreenState();
}

class _FindTheCountryScreenState extends State<FindTheCountryScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;

  late List<Map<String, String>> filteredCountries;

  bool gameOver = false;

  int _wrongAttempts = 0;

  Key _worldMapKey = UniqueKey();

  Map<String, String>? currentTarget;

  final Set<String> _correctCountryCodes = {};

  String? _hintedCountryCode; 

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    filteredCountries = (widget.region.toLowerCase() == 'world')
        ? List.from(countries)
        : countries
            .where((country) =>
                country['region']?.toLowerCase() ==
                widget.region.toLowerCase())
            .toList();

    gameOver = false;
    _wrongAttempts = 0;
    _correctCountryCodes.clear();
    _worldMapKey = UniqueKey();
    _hintedCountryCode = null;

    _pickNewCountry();

    if (!widget.isPractice) {
      _timer?.cancel();
      _startTimer();
    }

    setState(() {});
  }

  void _pickNewCountry() {
    if (filteredCountries.isEmpty) {
      _onGameFinished();
      return;
    }
    currentTarget =
        filteredCountries[Random().nextInt(filteredCountries.length)];
    _hintedCountryCode = null; 
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = widget.timeLimitMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _showTimeUpDialog();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Time's up!"),
        content: const Text('Your time is over.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _onGameFinished() {
    setState(() {
      gameOver = true;
      _timer?.cancel();
    });
  }

  void _handleWrongAttempt() {
    setState(() {
      _wrongAttempts++;
    });
  }

  void _restartGame() {
    _initGame();
  }

  void _handleGameOver() {
    _onGameFinished();
  }

  void _handleCorrectCountryTap(String tappedCountryCode) {
    final tappedLower = tappedCountryCode.toLowerCase();
    final targetCodeLower = currentTarget?['code']?.toLowerCase();

    if (targetCodeLower != null && tappedLower == targetCodeLower) {
      setState(() {
        _correctCountryCodes.add(tappedLower);
        filteredCountries
            .removeWhere((c) => c['code']?.toLowerCase() == tappedLower);
        if (filteredCountries.isEmpty) {
          _onGameFinished();
        } else {
          _pickNewCountry();
        }
      });
    } else {
      _handleWrongAttempt();
    }
  }

  void _showHint() {
    if (_hintedCountryCode != null || currentTarget == null) return;

    setState(() {
      _hintedCountryCode = currentTarget!['code'];
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget _buildErrorCounter() {
    if (widget.isPractice) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Wrong attempts: $_wrongAttempts',
        style: const TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPractice
            ? 'Practice Mode'
            : 'Time Left: ${_formatTime(_remainingSeconds)}'),
      ),
      body: Column(
        children: [
          _buildErrorCounter(),
          if (!gameOver && currentTarget != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Where is: ${currentTarget!['name']}?',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                WorldMapFindCountry(
                  key: _worldMapKey,
                  region: widget.region,
                  isPractice: widget.isPractice,
                  countries: filteredCountries,
                  onGameOver: _handleGameOver,
                  onWrongAttempt: _handleWrongAttempt,
                  onCountryTap: _handleCorrectCountryTap,
                  correctCountryCodes: _correctCountryCodes,
                  hintedCountryCode: _hintedCountryCode, 
                ),
                if (widget.isPractice)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ElevatedButton(
                      onPressed: _showHint,
                      child: const Text('Hint'),
                    ),
                  ),
              ],
            ),
          ),
          if (gameOver) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartGame,
              child: const Text('Restart'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChooseRegionScreen(gameType: widget.gameType),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Change Region'),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
