import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocation {
  final int id;
  final LatLng position;
  final String title;
  final String description;

  MapLocation({
    required this.id,
    required this.position,
    required this.title,
    required this.description,
  });
}