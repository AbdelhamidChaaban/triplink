// Importing necessary Dart and Flutter packages
import 'dart:convert'; // For decoding JSON responses from API
import 'package:flutter/material.dart'; // Provides UI components for Flutter apps
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For integrating Google Maps
import 'package:url_launcher/url_launcher.dart'; // For opening external links (Google Maps)
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // For decoding polyline route points
import '../../../config/maps_config.dart'; // Importing custom configuration for map settings

// Defining a StatefulWidget that displays a route between two locations on a map
class MapViewerScreen extends StatefulWidget {
  // Starting location (latitude and longitude)
  final LatLng startLocation;

  // Ending location (latitude and longitude)
  final LatLng endLocation;

  // Address name for the starting location
  final String startAddress;

  // Address name for the ending location
  final String endAddress;

  // Constructor for MapViewerScreen, requiring the start/end locations and addresses
  const MapViewerScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
  });

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState(); // Creating state
}

// Defining the state class for MapViewerScreen
class _MapViewerScreenState extends State<MapViewerScreen> {
  // Stores the polylines connecting locations (routes)
  Set<Polyline> _polylines = {};

  // Stores the markers representing locations on the map
  Set<Marker> _markers = {};

  // Loading flag to indicate when route data is being fetched
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute(); // Fetching route details as soon as the screen initializes
  }

  // Function to fetch route details from Google Maps Directions API
  Future<void> _fetchRoute() async {
    // Retrieving the API key from the MapsConfig file
    final apiKey = MapsConfig.browserApiKey;

    // Constructing the URL for Google Maps Directions API request
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.endLocation.latitude},${widget.endLocation.longitude}&key=$apiKey&mode=driving';

    // Sending a GET request to fetch directions
    final response = await http.get(Uri.parse(url));

    // Checking if the response was successful
    if (response.statusCode == 200) {
      // Decoding JSON response into a Dart object
      final data = json.decode(response.body);

      // Ensuring that the response contains route data
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        // Extracting the first route from the response
        final route = data['routes'][0];

        // Retrieving encoded polyline points for the route
        final overviewPolyline = route['overview_polyline']['points'];

        // Decoding the polyline points into a list of LatLng coordinates
        final polylinePoints = PolylinePoints().decodePolyline(overviewPolyline);
        final polylineCoords = polylinePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        // Updating state variables with fetched route data
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'), // Unique identifier for polyline
              points: polylineCoords, // Route coordinates
              color: Color(MapsConfig.polylineColor), // Route color from config
              width: MapsConfig.polylineWidth.toInt(), // Line thickness from config
            ),
          };

          _markers = {
            Marker(
              markerId: const MarkerId('start'), // Unique identifier for start location
              position: widget.startLocation, // Marker position
              infoWindow: InfoWindow(title: widget.startAddress), // Displayed info
            ),
            Marker(
              markerId: const MarkerId('end'), // Unique identifier for end location
              position: widget.endLocation, // Marker position
              infoWindow: InfoWindow(title: widget.endAddress), // Displayed info
            ),
          };

          _loading = false; // Mark loading as completed
        });
      }
    } else {
      // If request fails, simply stop loading
      setState(() {
        _loading = false;
      });
    }
  }

  // Function to open the selected route in Google Maps via an external URL
  void _openInGoogleMaps() async {
    // Constructing Google Maps URL with the specified start and end locations
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.endLocation.latitude},${widget.endLocation.longitude}&travelmode=driving',
    );

    // Checking if the URL can be launched
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Opens Google Maps externally
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and button to open route in Google Maps
      appBar: AppBar(
        title: const Text('Trip Route'), // Title displayed in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.map), // Map icon button
            onPressed: _openInGoogleMaps, // Calls function to open Google Maps
            tooltip: 'Open in Google Maps', // Tooltip text
          ),
        ],
      ),

      // Using Stack to overlay multiple UI components
      body: Stack(
        children: [
          // Google Map widget displaying route
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.startLocation, // Centering the map on the start location
              zoom: MapsConfig.defaultZoom, // Setting the default zoom level
            ),
            markers: _markers, // Displaying markers on the map
            polylines: _polylines, // Displaying route between locations
            myLocationEnabled: MapsConfig.enableMyLocation, // Showing user's location
            myLocationButtonEnabled: MapsConfig.enableMyLocationButton, // Enabling location button
            zoomControlsEnabled: MapsConfig.enableZoomControls, // Enabling zoom controls
            mapToolbarEnabled: MapsConfig.enableMapToolbar, // Enabling map toolbar options
            minMaxZoomPreference: MinMaxZoomPreference(
              MapsConfig.minZoom, // Minimum allowed zoom level
              MapsConfig.maxZoom, // Maximum allowed zoom level
            ),
          ),

          // Displays a loading indicator while the route is being fetched
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}