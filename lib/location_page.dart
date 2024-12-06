import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackerApp extends StatefulWidget {
  @override
  _LocationTrackerAppState createState() => _LocationTrackerAppState();
}

class _LocationTrackerAppState extends State<LocationTrackerApp> {
  GoogleMapController? _mapController;
  List<LatLng> _locationHistory = [];
  LatLng _currentLocation = const LatLng(23.822350, 90.365417) // set a default valu that does not give any null point exception. {safe from null}

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng(position.latitude, position.longitude);
      print('${_currentLocation.latitude}, ${_currentLocation.longitude}');
      _animateToCurrentLocation();
    } catch (e) {
      print('_getCurrentLocation $e');
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationHistory.add(_currentLocation);
        _updateMarkerAndPolyline();
      });
    });
  }

  void _animateToCurrentLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation,
          zoom: 15.0,
        ),
      ),
    );
  }

  void _updateMarkerAndPolyline() {
    // Update the marker position
    // Update the polyline connecting the previous and current locations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Location Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentLocation,
            infoWindow: InfoWindow(
              title: 'My current location',
              snippet:
                  'Latitude: ${_currentLocation.latitude}, Longitude: ${_currentLocation.longitude}',
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('location_history'),
            points: _locationHistory,
            color: Colors.blue,
            width: 4,
          ),
        },
      ),
    );
  }
}
