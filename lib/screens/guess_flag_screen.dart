import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/countries.dart';

class GuessFlagScreen extends StatefulWidget {
  final String region;
  const GuessFlagScreen({super.key, required this.region});

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

  @override
  void initState() {
    super.initState();
    _initCountryPool();
    _pickRandomCountry();
  }

  void _initCountryPool() {
    setState(() {
      if (widget.region == 'World') {
        remainingCountries = List.from(countries);
      } else {
      remainingCountries = countries
          .where((c) => c['region'] == widget.region)
          .toList();
      }  
    });
  }

  void _pickRandomCountry() {
    if (remainingCountries.isEmpty) {
      if(skippedCountries.isEmpty) {
        setState(() {
          message = 'Game over!';
          messageColor = Colors.blue;
       });
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
  }

  void _removeCurrentCountry() {
    remainingCountries.removeWhere(
      (country) => country['name'] == currentCountry['name'],
    );
  }

  void _checkAnswer(String answer) {
    final cleanedAnswer = answer.trim().toLowerCase();
    final correct = currentCountry['name']!.toLowerCase();
    if (cleanedAnswer == correct) {
      setState(() {
        message = 'Correct! 🎉';
        messageColor = Colors.green;
      });
      Timer(const Duration(seconds: 1), () {
        _removeCurrentCountry();
        setState(() {
          _pickRandomCountry();
        });
      });
    } else {
      setState(() {
        message = 'Keep trying...';
        messageColor = Colors.red;
      });
    }
  }

  void _skipFlag() {
  setState(() {
    skippedCountries.add(currentCountry);
    remainingCountries.removeWhere(
      (country) => country['name'] == currentCountry['name'],
    );
    _pickRandomCountry();
  });
}

  void _restartGame() {
    setState(() {
      _initCountryPool();
      _pickRandomCountry();
      message = '';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guess the Flag: ${widget.region}')),
      body: Padding(
       padding: const EdgeInsets.all(24),
       child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (remainingCountries.isNotEmpty)
                Column(
                  children: [
                    Image.asset(
                      'icons/flags/png/${currentCountry['code']}.png',
                      package: 'country_icons',
                      width: 200,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                       labelText: 'Type the country name',
                       border: OutlineInputBorder(),
                      ),
                      onChanged: _checkAnswer,
                    ),
                    const SizedBox(height: 12),
                    if (message.isNotEmpty)
                     Text(
                        message,
                       style: TextStyle(fontSize: 18, color: messageColor),
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                     onPressed: _skipFlag,
                     child: const Text('Skip'),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   Text(
                     message,
                     style: const TextStyle(fontSize: 20),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 20),
                   ElevatedButton(
                     onPressed: _restartGame,
                     child: const Text('Restart'),
                   ),
                   const SizedBox(height: 10),
                   ElevatedButton(
                     onPressed: () => Navigator.pop(context),
                     child: const Text('Back to region select'),
                   ),
                 ],
               ),
            ],
          ),
        ),
     ),
    );
  }
}
