import 'package:flutter/material.dart';
import 'guess_flag_screen.dart';

class ChooseRegionScreen extends StatelessWidget {
  const ChooseRegionScreen({super.key});

  // Mutăm lista într-o metodă pentru a evita eroarea de compilare
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
      appBar: AppBar(title: const Text('Choose Region')),
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
                      builder: (_) => GuessFlagScreen(region: region),
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
