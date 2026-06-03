import 'package:latlong2/latlong.dart';

class CoordinateParser {
  static LatLng? parse(String input) {
    final regex = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match == null) return null;

    final lat = double.parse(match.group(1)!);
    final lng = double.parse(match.group(2)!);

    return LatLng(lat, lng);
  }
}