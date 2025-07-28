import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorldMapFindCapital extends StatefulWidget {
  final String region;
  final bool isPractice;
  final List<Map<String, String>> countries;
  final VoidCallback? onGameOver;
  final VoidCallback? onWrongAttempt;
  final void Function(String countryCode)? onCapitalTap;
  final Set<String> correctCountryCodes;
  final String? hintedCountryCode; 
  
  const WorldMapFindCapital({
    super.key,
    required this.region,
    required this.isPractice,
    required this.countries,
    this.onGameOver,
    this.onWrongAttempt,
    this.onCapitalTap,
    this.correctCountryCodes = const {},
    this.hintedCountryCode,
  });

  @override
  State<WorldMapFindCapital> createState() => _WorldMapFindCapitalState();
}

class _WorldMapFindCapitalState extends State<WorldMapFindCapital>
    with SingleTickerProviderStateMixin {
  final List<CountryPolygon> _allCountryPolygons = [];
  final List<CountryPolygon> _filteredCountryPolygons = [];

  late Map<String, String> countryNameToCode;

  late AnimationController _animationController;
  late Animation<int> _pulseAnimation;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadGeoJson();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseAnimation = IntTween(begin: 80, end: 200).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.hintedCountryCode != null) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WorldMapFindCapital oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hintedCountryCode != oldWidget.hintedCountryCode) {
      if (widget.hintedCountryCode != null) {
        centerOnCountry(widget.hintedCountryCode!);
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _allCountryPolygons.where((cp) => allowedCountryNames.contains(cp.countryName)),
      );

      countryNameToCode = {
        for (var c in widget.countries) c['name']!: c['code']!.toLowerCase(),
      };
    });
  }

  void _handleTap(String tappedCountryName) {
    final tappedCode = countryNameToCode[tappedCountryName];
    if (tappedCode == null) return;

    if (widget.hintedCountryCode != null &&
        tappedCode == widget.hintedCountryCode!.toLowerCase()) {
      _animationController.stop();
    }

    if (widget.onCapitalTap != null) {
      widget.onCapitalTap!(tappedCode);
    }
  }

  void _handleMapTap(LatLng point) {
    final sortedCountries = [..._filteredCountryPolygons]..sort((a, b) {
      final aSize = a.rings.fold<int>(0, (sum, ring) => sum + ring.length);
      final bSize = b.rings.fold<int>(0, (sum, ring) => sum + ring.length);
      return aSize.compareTo(bSize); 
    });

    for (final country in sortedCountries) {
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

  void centerOnCountry(String countryCode) {
    final polygon = _filteredCountryPolygons.firstWhere(
      (cp) {
        final code = widget.countries.firstWhere(
          (c) => c['name'] == cp.countryName,
          orElse: () => {},
        )['code'];
        return code != null && code.toLowerCase() == countryCode.toLowerCase();
      },
      orElse: () => CountryPolygon(countryName: '', rings: []),
    );

    if (polygon.rings.isEmpty) return;

    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (final ring in polygon.rings) {
      for (final point in ring) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    double zoom = 5.0;
    if (latDiff > 20 || lngDiff > 20) {
      zoom = 3.0;
    } else if (latDiff > 10 || lngDiff > 10) {
      zoom = 4.0;
    } else if (latDiff > 5 || lngDiff > 5) {
      zoom = 5.0;
    } else {
      zoom = 6.0;
    }

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  @override
  Widget build(BuildContext context) {
    final center = _getRegionCenter(widget.region);
    final zoom = _getRegionZoom(widget.region);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
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
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return PolygonLayer(
                polygons: _filteredCountryPolygons.expand((cp) {
                  final countryCode = countryNameToCode[cp.countryName];
                  final isCorrect =
                      countryCode != null && widget.correctCountryCodes.contains(countryCode);
                  final isHinted =
                      widget.hintedCountryCode != null &&
                      countryCode == widget.hintedCountryCode!.toLowerCase();

                  return cp.rings.map((ring) {
                    return Polygon(
                      points: ring,
                      color: isCorrect
                          ? Colors.green.withAlpha(150)
                          : isHinted
                              ? Colors.green.withAlpha(_pulseAnimation.value)
                              : Colors.grey.withAlpha(25),
                      borderColor: isCorrect
                          ? Colors.green
                          : isHinted
                              ? Colors.green.withAlpha(200)
                              : Colors.black.withAlpha(50),
                      borderStrokeWidth: isCorrect || isHinted ? 2 : 0.5,
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
              );
            },
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
