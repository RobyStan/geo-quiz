import 'package:flutter/material.dart';
import 'choose_game_mode_screen.dart';
import 'package:geo_quiz_app/models/game_type.dart';

class ChooseRegionScreen extends StatelessWidget {
    final GameType gameType;

  const ChooseRegionScreen({super.key, required this.gameType});

  List<String> get regions => const [
        'World',
        'Europe',
        'Asia',
        'Africa',
        'America',
        'Oceania',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Region'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView.builder(
          itemCount: regions.length,
          itemBuilder: (context, index) {
            final region = regions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChooseGameModeScreen(region: region,  gameType: gameType,),
                    ),
                  );
                },
                child: Text(region),
              ),
            );
          },
        ),
      ),
    );
  }
}
