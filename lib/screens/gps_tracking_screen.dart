import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  // Default ke Jakarta sampai lokasi pertama didapat
  static const _defaultCenter = LatLng(-6.2088, 106.8456);
  // Perkiraan kasar kalori yang terbakar per km lari/jalan cepat
  static const _kcalPerKm = 60.0;

  final _mapController = MapController();
  final List<LatLng> _route = [];

  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  double _distanceMeters = 0;
  LatLng? _currentPosition;
  bool _isRunning = false;
  bool _mapReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _error = "GPS tidak aktif. Nyalakan layanan lokasi.");
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _error = "Izin lokasi ditolak.");
      return false;
    }
    return true;
  }

  Future<void> _startTracking() async {
    if (!await _ensurePermission() || !mounted) return;
    setState(() {
      _error = null;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
    ).listen(_onPosition, onError: (_) {
      if (mounted) setState(() => _error = "Gagal membaca lokasi.");
    });
  }

  void _onPosition(Position position) {
    final point = LatLng(position.latitude, position.longitude);
    setState(() {
      if (_route.isNotEmpty) {
        final last = _route.last;
        _distanceMeters += Geolocator.distanceBetween(
          last.latitude, last.longitude, point.latitude, point.longitude,
        );
      }
      _route.add(point);
      _currentPosition = point;
    });
    if (_mapReady) _mapController.move(point, _mapController.camera.zoom);
  }

  void _togglePause() {
    if (_isRunning) {
      _positionSub?.pause();
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else if (_positionSub == null) {
      _startTracking();
    } else {
      _positionSub!.resume();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
      setState(() => _isRunning = true);
    }
  }

  void _recenter() {
    final pos = _currentPosition;
    if (pos != null && _mapReady) _mapController.move(pos, 17);
  }

  String get _timeText {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? "$h:$m:$s" : "$m:$s";
  }

  String get _paceText {
    final km = _distanceMeters / 1000;
    if (km < 0.01) return "-:--";
    final secPerKm = _elapsed.inSeconds / km;
    final m = secPerKm ~/ 60;
    final s = (secPerKm % 60).round().toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final km = _distanceMeters / 1000;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultCenter,
              initialZoom: 17,
              onMapReady: () {
                _mapReady = true;
                _recenter();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.moveup',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: _route, color: primary, strokeWidth: 5),
                ],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.my_location, color: Colors.black),
                          onPressed: _recenter,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.white.withValues(alpha: 0.8),
                        child: const Text("© OpenStreetMap", style: TextStyle(fontSize: 10, color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_error != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 72, left: 16, right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),

          // Bottom Stats Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_timeText, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                  const Text("Durasi", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(km.toStringAsFixed(2), "KM"),
                      _buildMiniStat(_paceText, "Pace"),
                      _buildMiniStat((km * _kcalPerKm).round().toString(), "Kcal"),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
