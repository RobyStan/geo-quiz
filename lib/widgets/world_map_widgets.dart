import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorldMapScreen extends StatefulWidget {
  final String region;
  final Set<String> guessedCountries;
  
  const WorldMapScreen({
    super.key,
    required this.region,
    required this.guessedCountries,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  final List<CountryPolygon> countryPolygons = [];

  @override
  void initState() {
    super.initState();
    loadGeoJson();
  }

  String getGeoJsonFileName(String region) {
    switch (region.toLowerCase()) {
      case 'europe':
        return 'assets/geo/europe.geo.json';
      case 'oceania':
        return 'assets/geo/oceania.geo.json';
      case 'america':
        return 'assets/geo/america.geo.json';
      case 'africa':
        return 'assets/geo/africa.geo.json';
      case 'asia':
        return 'assets/geo/asia.geo.json';
      case 'world':
      default:
        return 'assets/geo/world.geo.json';
    }
  }

  LatLng getRegionCenter(String region) {
    switch (region.toLowerCase()) {
      case 'europe':
        return LatLng(54.0, 15.0);
      case 'oceania':
        return LatLng(-22.0, 140.0);
      case 'america':
        return LatLng(15.0, -75.0);
      case 'africa':
        return LatLng(1.5, 20.0);
      case 'asia':
        return LatLng(34.0, 100.0);
      case 'world':
      default:
        return LatLng(20.0, 0.0);
    }
 }

  double getRegionZoom(String region) {
    switch (region.toLowerCase()) {
      case 'europe':
        return 4.0;
      case 'oceania':
        return 3.5;
      case 'america':
        return 3.0;
      case 'africa':
        return 3.0;
      case 'asia':
        return 3.0;
      case 'world':
      default:
        return 2.0;
    } 
 }

  Future<void> loadGeoJson() async {
    final fileName = getGeoJsonFileName(widget.region);
    final data = await rootBundle.loadString(fileName);
    final Map<String, dynamic> json = jsonDecode(data);

    final features = json['features'] as List<dynamic>;
    countryPolygons.clear();

    for (final feature in features) {
      final props = feature['properties'];
      final geometry = feature['geometry'];
      final type = geometry['type'];
      final coordinates = geometry['coordinates'];

      final countryName = props['admin'];

      List<List<LatLng>> rings = [];

      if (type == 'Polygon') {
        final exteriorRing = coordinates[0];
        final polygon = exteriorRing.map<LatLng>((p) => LatLng(
          (p[1] as num).toDouble(),
          (p[0] as num).toDouble(),
        )).toList();
        rings.add(polygon);
      } else if (type == 'MultiPolygon') {
        for (final polygon in coordinates) {
          final exteriorRing = polygon[0];
          final latlngRing = exteriorRing.map<LatLng>((p) => LatLng(
            (p[1] as num).toDouble(),
            (p[0] as num).toDouble(),
          )).toList();
          rings.add(latlngRing);
        }
      }

      if (rings.isNotEmpty) {
        countryPolygons.add(CountryPolygon(
          countryName: countryName,
          rings: rings,
        ));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final center = getRegionCenter(widget.region);
    final zoom = getRegionZoom(widget.region);

    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: zoom,
        maxZoom: 8,
        minZoom: 1,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.geoquiz',
        ),
        PolygonLayer(
          polygons: countryPolygons.expand((cp) {
            final guessed = widget.guessedCountries.contains(cp.countryName);
            return cp.rings.map((ring) => Polygon(
                  points: ring,
                  color: guessed
                      ? Colors.green.withAlpha(180)
                      : Colors.grey.withAlpha(30),
                  borderColor: guessed
                      ? Colors.green.withAlpha(255)
                      : Colors.grey.withAlpha(100),
                  borderStrokeWidth: guessed ? 2.0 : 1.0,
                  isFilled: true,
                ));
          }).toList(),
        ),
      ],
    );
  }
}

class CountryPolygon {
  final String countryName;
  final List<List<LatLng>> rings;

  CountryPolygon({
    required this.countryName,
    required this.rings,
  });
}
