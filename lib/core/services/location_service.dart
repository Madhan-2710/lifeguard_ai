import 'dart:async';

import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

/// Result of a successful location capture.
class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.mapsLink,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  /// Google Maps deep link for the captured coordinates.
  final String mapsLink;
}

/// Abstraction over device location so the SOS flow can be unit tested.
abstract class LocationService {
  /// Resolves the current device location.
  ///
  /// Throws [PermissionException] when location permission is missing or
  /// permanently denied, and [LocationException] when the location service is
  /// disabled, the request times out, or the lookup fails.
  Future<LocationResult> getCurrentLocation();
}

/// Geolocator-backed implementation with full permission handling.
class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService({this.timeout = const Duration(seconds: 15)});

  /// Maximum time to wait for a GPS fix.
  final Duration timeout;

  @override
  Future<LocationResult> getCurrentLocation() async {
    // 1. Location service (GPS / network) enabled?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        message:
            'Location services are disabled. '
            'Please enable them in your device settings.',
      );
    }

    // 2. Permission checks.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionException(
          message:
              'Location permission was denied. '
              'SOS cannot capture your location without it.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw PermissionException(
        message:
            'Location permission is permanently denied. '
            'Enable it in app settings to use SOS.',
      );
    }

    // 3. Capture position.
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      final timestamp = DateTime.now();
      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: timestamp,
        mapsLink:
            'https://www.google.com/maps/search/?api=1'
            '&query=${position.latitude},${position.longitude}',
      );
    } on TimeoutException {
      throw LocationException(
        message: 'Location request timed out. Please try again.',
      );
    } catch (e) {
      throw LocationException(
        message: 'Unable to get your current location. Please try again.',
      );
    }
  }
}
