import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zavod_assessment_app/data/models/map_location_model.dart';
import 'package:zavod_assessment_app/presentation/components/custom_btn.dart';
import 'package:zavod_assessment_app/utils/app_colors.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final List<MapLocation> locations;
  final Function(MapLocation) onLocationSelected;

  const MapScreen({
    super.key,
    required this.locations,
    required this.onLocationSelected,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? userLocation;


  @override
  void initState() {
    super.initState();
    _createMarkers();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          "Location permissions are permanently denied. Enable in settings.",
        )),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(userLocation!),
    );
  }


  Future<BitmapDescriptor> _getCustomMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/png_files/restaurant_1.png',
    );
  }

  Future<void> _createMarkers()async {
    final customIcon = await _getCustomMarker();
    setState(() {
      markers = widget.locations.map((location) {
        return Marker(
          markerId: MarkerId(location.id.toString()),
          position: location.position,
          icon: customIcon,
          infoWindow: InfoWindow(
            title: location.title,
            snippet: location.description,
          ),
          onTap: () {
            _showOverlay(location);
          },
        );
      }).toSet();
    });
  }


  void _showOverlay(MapLocation location) async {
    String address = await _getAddressFromLatLng(location.position); // Ensure we have the address before displaying
    _removeOverlay();
    final ValueNotifier<double> opacity = ValueNotifier(0.0);
    final ValueNotifier<Offset> slideOffset = ValueNotifier(const Offset(0, 0.1));
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: ValueListenableBuilder<double>(
            valueListenable: opacity,
            builder: (context, op, child) {
              return AnimatedOpacity(
                opacity: op,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: slideOffset,
                  builder: (context, offset, child) {
                    return AnimatedSlide(
                      offset: offset,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:  [
                            BoxShadow(
                              color: Colors.black26.withValues(alpha: .5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _removeOverlay,
                                child: const Icon(Icons.close, color: Colors.grey),
                              ),
                            ),
                            Text(
                              address,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              location.description,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            CustomAppButton(
                              width: 100,
                              voidCallback: () {
                                _navigateToLocation(location);
                                _removeOverlay();
                              },
                              title:"Navigate",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
    Future.delayed(const Duration(milliseconds: 10), () {
      opacity.value = 1.0;
      slideOffset.value = Offset.zero;
    });
  }




  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.name} ${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}".trim();
      }
    } catch (e) {
      return "Address not found";
    }
    return "Address not found";
  }




  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _navigateToLocation(MapLocation location) async {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fetching user location...")),
      );
      await _getUserLocation();
      if (userLocation == null) return;
    }

    try {
      List<LatLng> routePoints = await getRouteCoordinates(userLocation!, location.position);

      setState(() {
        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: AppColors.kbg,
            width: 5,
            points: routePoints,
            visible: true,
          ),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              userLocation!.latitude < location.position.latitude
                  ? userLocation!.latitude
                  : location.position.latitude,
              userLocation!.longitude < location.position.longitude
                  ? userLocation!.longitude
                  : location.position.longitude,
            ),
            northeast: LatLng(
              userLocation!.latitude > location.position.latitude
                  ? userLocation!.latitude
                  : location.position.latitude,
              userLocation!.longitude > location.position.longitude
                  ? userLocation!.longitude
                  : location.position.longitude,
            ),
          ),
          100.0,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigating to ${location.title}...")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch route!")),
      );
    }
  }


  Future<List<LatLng>> getRouteCoordinates(LatLng origin, LatLng destination) async {
    const String apiKey = "AIzaSyDVADxxQslZpdjFl6spupztXgLJ_B_lKSI"; // Replace with your API key
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if ((data["routes"] as List).isEmpty) return [];

      List<LatLng> polylineCoordinates = [];

      var steps = data["routes"][0]["legs"][0]["steps"];
      for (var step in steps) {
        var start = step["start_location"];
        var end = step["end_location"];
        polylineCoordinates.add(LatLng(start["lat"], start["lng"]));
        polylineCoordinates.add(LatLng(end["lat"], end["lng"]));
      }
      return polylineCoordinates;
    } else {
      throw Exception("Failed to load route");
    }
  }


  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }
  void _applyMapStyle(GoogleMapController controller) async {
    String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    controller.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(6.5244, 3.3792),
            zoom: 12,
          ),
          markers: markers,
          polylines: polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            _applyMapStyle(controller);
          },
        ),
        Positioned(
          top: 100,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                onPressed: _zoomIn,
                backgroundColor: AppColors.kbg,
                mini: true,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "zoom_out",
                onPressed: _zoomOut,
                backgroundColor: AppColors.kbg,
                mini: true,
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

