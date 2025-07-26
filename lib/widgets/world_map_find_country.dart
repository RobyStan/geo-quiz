import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorldMapFindCountry extends StatefulWidget {
  final String region;
  final bool isPractice;
  final List<Map<String, String>> countries;
  final VoidCallback? onGameOver;
  final VoidCallback? onWrongAttempt;

  const WorldMapFindCountry({
    super.key,
    required this.region,
    required this.isPractice,
    required this.countries,
    this.onGameOver,
    this.onWrongAttempt,
  });

  @override
  State<WorldMapFindCountry> createState() => _WorldMapFindCountryState();
}

class _WorldMapFindCountryState extends State<WorldMapFindCountry> {
  final List<CountryPolygon> _allCountryPolygons = [];
  final List<CountryPolygon> _filteredCountryPolygons = [];
  final Set<String> _correctCountries = {};
  String? _targetCountry;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    final fileName = _getGeoJsonFileName(widget.region);
    final data = await rootBundle.loadString(fileName);
    final Map<String, dynamic> json = jsonDecode(data);

    final features = json['features'] as List<dynamic>;
    final loadedPolygons = <CountryPolygon>[];

    for (final feature in features) {
      final props = feature['properties'];
      final geometry = feature['geometry'];
      final type = geometry['type'];
      final coordinates = geometry['coordinates'];
      final countryName = props['admin'];

      List<List<LatLng>> rings = [];

      if (type == 'Polygon') {
        final exteriorRing = coordinates[0];
        final polygon = exteriorRing
            .map<LatLng>((p) => LatLng(
                  (p[1] as num).toDouble(),
                  (p[0] as num).toDouble(),
                ))
            .toList();
        rings.add(polygon);
      } else if (type == 'MultiPolygon') {
        for (final polygon in coordinates) {
          final exteriorRing = polygon[0];
          final latlngRing = exteriorRing
              .map<LatLng>((p) => LatLng(
                    (p[1] as num).toDouble(),
                    (p[0] as num).toDouble(),
                  ))
              .toList();
          rings.add(latlngRing);
        }
      }

      if (rings.isNotEmpty) {
        loadedPolygons.add(CountryPolygon(
          countryName: countryName,
          rings: rings,
        ));
      }
    }

    setState(() {
      _allCountryPolygons.clear();
      _allCountryPolygons.addAll(loadedPolygons);

      final allowedCountryNames = widget.countries.map((c) => c['name']).toSet();
      _filteredCountryPolygons.clear();
      _filteredCountryPolygons.addAll(
          _allCountryPolygons.where((cp) => allowedCountryNames.contains(cp.countryName)));

      _correctCountries.clear();
      _chooseNextCountry();
    });
  }

  void _chooseNextCountry() {
    final remaining = _filteredCountryPolygons
        .map((c) => c.countryName)
        .where((name) => !_correctCountries.contains(name))
        .toList();

    if (remaining.isEmpty) {
      setState(() {
        _targetCountry = null;
      });

      if (widget.onGameOver != null) {
        widget.onGameOver!();
      }
    } else {
      remaining.shuffle();
      setState(() {
        _targetCountry = remaining.first;
      });
    }
  }

  void _handleTap(String tappedCountry) {
    if (_targetCountry == null) return;

    if (tappedCountry == _targetCountry) {
      setState(() {
        _correctCountries.add(tappedCountry);
        _chooseNextCountry();
      });
    } else {
      widget.onWrongAttempt?.call();
    }
  }

  void _handleMapTap(LatLng point) {
    for (final country in _filteredCountryPolygons) {
      for (final ring in country.rings) {
        if (_isPointInPolygon(point, ring)) {
          _handleTap(country.countryName);
          return;
        }
      }
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < point.latitude &&
              polygon[j].latitude >= point.latitude ||
          polygon[j].latitude < point.latitude &&
              polygon[i].latitude >= point.latitude) &&
          (polygon[i].longitude <= point.longitude ||
              polygon[j].longitude <= point.longitude)) {
        if (polygon[i].longitude +
                (point.latitude - polygon[i].latitude) /
                    (polygon[j].latitude - polygon[i].latitude) *
                    (polygon[j].longitude - polygon[i].longitude) <
            point.longitude) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return oddNodes;
  }

  @override
  Widget build(BuildContext context) {
    final center = _getRegionCenter(widget.region);
    final zoom = _getRegionZoom(widget.region);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Find: ${_targetCountry ?? "Finished!"}'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: zoom,
          maxZoom: 8,
          minZoom: 1,
          onTap: (tapPosition, latlng) {
            _handleMapTap(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.geoquiz',
          ),
          PolygonLayer(
            polygons: _filteredCountryPolygons.expand((cp) {
              final isCorrect = _correctCountries.contains(cp.countryName);
              return cp.rings.map((ring) {
                return Polygon(
                  points: ring,
                  color: isCorrect
                      ? Colors.green.withAlpha(150)
                      : Colors.grey.withAlpha(25),
                  borderColor:
                      isCorrect ? Colors.green : Colors.black.withAlpha(50),
                  borderStrokeWidth: isCorrect ? 2 : 0.5,
                  isFilled: true,
                  label: cp.countryName,
                  labelStyle: widget.isPractice
                      ? const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )
                      : const TextStyle(
                          color: Colors.transparent,
                        ),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getGeoJsonFileName(String region) {
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

  LatLng _getRegionCenter(String region) {
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

  double _getRegionZoom(String region) {
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
}

class CountryPolygon {
  final String countryName;
  final List<List<LatLng>> rings;

  CountryPolygon({
    required this.countryName,
    required this.rings,
  });
}
