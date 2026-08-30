import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({required this.latitude, required this.longitude});

  String get googleMapsUrl => 'https://maps.google.com/?q=$latitude,$longitude';
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const MethodChannel _nativeChannel = MethodChannel('com.roadsos.mobile/native');

  /// Default fallback location coordinates
  static const double defaultLat = 13.0067;
  static const double defaultLng = 80.2206;

  /// Retrieves FRESH live satellite GPS coordinates across any location
  Future<LocationData> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          // ALWAYS query a FRESH active satellite GPS fix first (high accuracy)!
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          return LocationData(latitude: pos.latitude, longitude: pos.longitude);
        }
      }
    } catch (_) {}

    // Fallback to getLastKnownPosition only if fresh satellite lookup times out
    try {
      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        return LocationData(latitude: lastPos.latitude, longitude: lastPos.longitude);
      }
    } catch (_) {}

    return await _fallbackNativeGps();
  }

  Future<LocationData> _fallbackNativeGps() async {
    try {
      final Map? map = await _nativeChannel.invokeMethod<Map>('getCurrentGpsLocation');
      if (map != null && map['latitude'] != null && map['longitude'] != null) {
        final double lat = (map['latitude'] as num).toDouble();
        final double lng = (map['longitude'] as num).toDouble();
        return LocationData(latitude: lat, longitude: lng);
      }
    } catch (_) {}

    return LocationData(latitude: defaultLat, longitude: defaultLng);
  }

  /// Formats latitude and longitude into a clickable Google Maps URL
  static String formatGoogleMapsUrl(double lat, double lng) {
    return 'https://maps.google.com/?q=$lat,$lng';
  }
}
