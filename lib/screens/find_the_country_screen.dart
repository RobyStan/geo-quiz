import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/world_map_find_country.dart';
import 'home_screen.dart';
import 'choose_region_screen.dart';
import '../models/game_type.dart';
import '../data/countries.dart';

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
  int secondsLeft = 0;

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
                country['region']?.toLowerCase() == widget.region.toLowerCase())
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
    currentTarget = filteredCountries[Random().nextInt(filteredCountries.length)];
    _hintedCountryCode = null;
  }

  void _startTimer() {
    setState(() {
      secondsLeft = widget.timeLimitMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/find_the_country.jpg',
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
                          widget.isPractice
                              ? 'Guess the country'
                              : 'Time Left: ${_formatTime(secondsLeft)}',
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
    return Column(
      children: [
        if (!widget.isPractice)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '❌ $_wrongAttempts mistakes',
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
          ),
        if (currentTarget != null && currentTarget!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Where is: ${currentTarget!['name']}?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
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
                  child: ElevatedButton.icon(
                    onPressed: _showHint,
                    icon: const Icon(Icons.visibility, color: Colors.green),
                    label: const Text(
                      'Hint',
                      style: TextStyle(color: Colors.green),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(175),
                      foregroundColor: Colors.black,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🎉 You found all countries!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '❌ $_wrongAttempts mistakes',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: Offset(1, 1),
              ),
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
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ChooseRegionScreen(gameType: widget.gameType),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(175),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Change Region 🌍'),
          ),
        ),
      ],
    );
  }
}
