import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final distance = Distance();

double getDistanceInKm({
  required double userLat,
  required double userLng,
  required double hospitalLat,
  required double hospitalLng,
}) {
  return distance.as(
    LengthUnit.Kilometer,
    LatLng(userLat, userLng),
    LatLng(hospitalLat, hospitalLng),
  );
}


Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location service is enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Check permission
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
      'Location permission permanently denied. Open app settings.',
    );
  }

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
}