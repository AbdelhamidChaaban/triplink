// Importing necessary Flutter material package for UI components
import 'package:flutter/material.dart';

// Importing Google Maps package for integrating maps in the application
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Defining a StatefulWidget for selecting locations on the map
class MapPickerScreen extends StatefulWidget {
  // Optional initial location when opening the map
  final LatLng? initialLocation;

  // Callback function triggered when locations are selected (start & end points)
  final void Function(LatLng start, LatLng end)? onLocationsSelected;

  // Boolean flag to determine if only a single location needs to be selected
  final bool singleLocationMode;

  // Optional hue value for marker color customization
  final double? markerHue;

  // Constructor to initialize the MapPickerScreen with optional parameters
  const MapPickerScreen({
    super.key,
    this.initialLocation,
    this.onLocationsSelected,
    this.singleLocationMode = false, // Default value: false
    this.markerHue,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState(); // Creating state
}

// Defining the state class for MapPickerScreen
class _MapPickerScreenState extends State<MapPickerScreen> {
  // Controller for managing the Google Map
  GoogleMapController? _mapController;

  // Stores the user's selected start location
  LatLng? _startLocation;

  // Stores the user's selected end location
  LatLng? _endLocation;

  // Stores all markers placed on the map
  Set<Marker> _markers = {};

  // Stores polylines connecting locations on the map (used for routes)
  Set<Polyline> _polylines = {};

  // Stores the single selected location (used in singleLocationMode)
  LatLng? _singleLocation;

  @override
  void initState() {
    super.initState();
    
    // Logging initial state details for debugging
    print('MapPickerScreen initState: _markers = $_markers, _startLocation = $_startLocation, _endLocation = $_endLocation');
    
    // Ensuring no markers are set initially
    // The map opens blank, and users manually select start and end locations
  }

  // Handles map taps, allowing users to select locations
  void _onMapTap(LatLng location) {
    // Logging tapped location details for debugging
    print('MapPickerScreen _onMapTap: tapped at ${location.latitude}, ${location.longitude}');

    // Handling single location selection mode
    if (widget.singleLocationMode) {
      setState(() {
        _singleLocation = location; // Assign tapped location as the single location
        
        // Setting a marker for the selected location
        _markers = {
          Marker(
            markerId: const MarkerId('single'),
            position: location,
            infoWindow: const InfoWindow(title: 'Selected Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(widget.markerHue ?? BitmapDescriptor.hueBlue),
          ),
        };
      });
      return; // Exit function early for single location mode
    }

    // Handling normal route selection (start & end locations)
    setState(() {
      if (_startLocation == null) {
        _startLocation = location; // Assign tapped location as start location
        
        // Creating a marker for the pickup location
        _markers = {
          Marker(
            markerId: const MarkerId('start'),
            position: location,
            infoWindow: const InfoWindow(title: 'Pickup Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        };
        
        // Logging selected start location for debugging
        print('Set start location: $_startLocation, _markers = $_markers');
      } else if (_endLocation == null) {
        _endLocation = location; // Assign tapped location as end location
        
        // Adding a marker for the dropoff location
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: location,
            infoWindow: const InfoWindow(title: 'Dropoff Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          ),
        );

        // Creating a polyline connecting start and end locations
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_startLocation!, location],
            color: Colors.blue,
            width: 5,
          ),
        };

        // Logging selected end location for debugging
        print('Set end location: $_endLocation, _markers = $_markers');
      }
    });
  }

  // Confirms the selected start and end locations and passes them back
  void _confirmRoute() {
    if (_startLocation != null && _endLocation != null) {
      if (widget.onLocationsSelected != null) {
        widget.onLocationsSelected!(_startLocation!, _endLocation!); // Trigger callback
      }
      Navigator.pop(context); // Close the screen after confirmation
    }
  }

  // Confirms the single location selection and returns it
  void _confirmSingleLocation() {
    if (_singleLocation != null) {
      Navigator.pop(context, _singleLocation); // Close screen with selected location
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title 'Select Route on Map'
      appBar: AppBar(title: const Text('Select Route on Map')),
      
      // Using Stack to overlay multiple UI elements
      body: Stack(
        children: [
          // Google Map widget for selecting locations
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(31.9522, 35.9241), // Default map position (Jordan)
              zoom: 15, // Initial zoom level
            ),
            onMapCreated: (controller) => _mapController = controller, // Assigns map controller
            onTap: _onMapTap, // Handles map tap interactions
            markers: _markers, // Displays markers on the map
            polylines: _polylines, // Displays routes connecting locations
            myLocationEnabled: true, // Enables showing user’s current location
            myLocationButtonEnabled: true, // Adds a button to center map on user location
          ),

          // Displays 'Confirm Location' button if single location is selected
          if (widget.singleLocationMode && _singleLocation != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _confirmSingleLocation, // Calls confirmation function
                child: const Text('Confirm Location'),
              ),
            ),

          // Displays 'Confirm Route' button if both start and end locations are selected
          if (_startLocation != null && _endLocation != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _confirmRoute, // Calls route confirmation function
                child: const Text('Confirm Route'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose(); // Disposes the Google Map controller when screen is closed
    super.dispose(); // Calls superclass dispose method
  }
}