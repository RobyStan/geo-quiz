import 'package:flutter/material.dart';
import 'guess_flag_screen.dart';

class ChooseGameModeScreen extends StatelessWidget {
  final String region;
  const ChooseGameModeScreen({super.key, required this.region});

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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuessFlagScreen(
                        region: region,
                        isPractice: true,
                        timeLimitMinutes: getTimeLimitForRegion(region),
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
                        timeLimitMinutes: getTimeLimitForRegion(region),
                      ),
                    ),
                  );
                },
                child: const Text('Timed Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
