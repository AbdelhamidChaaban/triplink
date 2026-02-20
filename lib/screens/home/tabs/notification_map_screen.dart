import 'package:flutter/material.dart'; // Import Flutter material design library
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps Flutter

class NotificationMapScreen extends StatelessWidget { // Define NotificationMapScreen widget
  final double pickupLat; // Pickup latitude
  final double pickupLng; // Pickup longitude
  final double dropoffLat; // Dropoff latitude
  final double dropoffLng; // Dropoff longitude

  const NotificationMapScreen({ // Constructor for NotificationMapScreen
    Key? key, // Optional key
    required this.pickupLat, // Require pickup latitude
    required this.pickupLng, // Require pickup longitude
    required this.dropoffLat, // Require dropoff latitude
    required this.dropoffLng, // Require dropoff longitude
  }) : super(key: key); // Call super constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    final LatLng pickup = LatLng(pickupLat, pickupLng); // Create LatLng for pickup
    final LatLng dropoff = LatLng(dropoffLat, dropoffLng); // Create LatLng for dropoff
    final Set<Marker> markers = { // Set of markers for the map
      Marker( // Pickup marker
        markerId: const MarkerId('pickup'), // Marker ID
        position: pickup, // Marker position
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker
        infoWindow: const InfoWindow(title: 'Pickup'), // Info window
      ), // End of pickup marker
      Marker( // Dropoff marker
        markerId: const MarkerId('dropoff'), // Marker ID
        position: dropoff, // Marker position
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow), // Yellow marker
        infoWindow: const InfoWindow(title: 'Dropoff'), // Info window
      ), // End of dropoff marker
    }; // End of markers set
    final Set<Polyline> polylines = { // Set of polylines for the map
      Polyline( // Polyline for route
        polylineId: const PolylineId('route'), // Polyline ID
        color: Colors.blueAccent, // Polyline color
        width: 5, // Polyline width
        points: [pickup, dropoff], // Points for the polyline
      ), // End of Polyline
    }; // End of polylines set
    return Scaffold( // Return Scaffold widget
      appBar: AppBar(title: const Text('Notification Map')), // App bar title
      body: GoogleMap( // Google Map widget
        initialCameraPosition: CameraPosition( // Initial camera position
          target: LatLng( // Center between pickup and dropoff
            (pickupLat + dropoffLat) / 2, // Average latitude
            (pickupLng + dropoffLng) / 2, // Average longitude
          ), // End of LatLng
          zoom: 12, // Initial zoom level
        ), // End of CameraPosition
        markers: markers, // Set of markers
        polylines: polylines, // Set of polylines
        myLocationButtonEnabled: false, // Hide my location button
        zoomControlsEnabled: true, // Show zoom controls
      ), // End of GoogleMap
    ); // End of Scaffold
  } // End of build method
} // End of NotificationMapScreen class 