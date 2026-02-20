// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import Google Maps Flutter package for map functionality
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Import trip service for managing trip data operations
import '../../../services/trip_service.dart';
// Import trip model for trip data structure
import '../../../models/trip_model.dart';
// Import trip request model for request data structure
import '../../../models/trip_request_model.dart';
// Import trip details screen for viewing trip details
import 'trip_details_screen.dart';
// Import Cloud Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Import auth service for user authentication
import '../../../services/auth_service.dart';
// Import chat room screen for messaging functionality
import 'chat_room_screen.dart';

// Define SearchTab as a stateful widget for managing search functionality
class SearchTab extends StatefulWidget {
  // Constructor for SearchTab
  const SearchTab({super.key});

  @override
  // Create state for SearchTab
  State<SearchTab> createState() => _SearchTabState();
}

// Define the state class for SearchTab
class _SearchTabState extends State<SearchTab> {
  // Create instance of trip service for managing trips
  final _tripService = TripService();
  // Controller for Google Maps
  GoogleMapController? _mapController;
  // Set to store all markers on the map
  Set<Marker> _markers = {};
  // Set to store trip markers (red)
  Set<Marker> _tripMarkers = {};
  // Set to store request markers (green)
  Set<Marker> _requestMarkers = {};
  // Set to store polylines for routes
  Set<Polyline> _polylines = {};
  // Controller for start location text input
  final _startLocationController = TextEditingController();
  // Controller for end location text input
  final _endLocationController = TextEditingController();
  // Store start location filter
  String? _startLocation;
  // Store end location filter
  String? _endLocation;

  @override
  // Initialize state when widget is created
  void initState() {
    // Call parent class initState
    super.initState();
    // Load trips and requests when screen initializes
    _loadTripsAndRequests();
  }

  @override
  // Clean up resources when widget is disposed
  void dispose() {
    // Dispose text controllers
    _startLocationController.dispose();
    // Dispose text controllers
    _endLocationController.dispose();
    // Dispose map controller
    _mapController?.dispose();
    // Call parent class dispose
    super.dispose();
  }

  // Method to load trips and requests from Firestore
  void _loadTripsAndRequests() {
    // Listen to trips stream and update markers when trips change
    _tripService.getAllTrips().listen((trips) {
      // Update trip markers on the map
      _updateTripMarkers(trips);
    });

    // Listen to trip requests stream and update markers when requests change
    _tripService.getAllTripRequests().listen((requests) {
      // Update request markers on the map
      _updateRequestMarkers(requests);
    });
  }

  // Method to update trip markers on the map
  void _updateTripMarkers(List<TripModel> trips) {
    // Log number of trips received
    print('Trips received: ${trips.length}');
    // Get current time for filtering
    final now = DateTime.now();
    // Filter and map trips to markers
    final markers = trips
      .where((trip) =>
        trip.status == 'public' && // Only show public trips
        trip.availableSeats > 0 && // Only show trips with available seats
        now.difference(trip.createdAt).inHours < 24 && // Only show trips less than 24 hours old
        (_startLocation == null || trip.startLocation.toLowerCase().contains(_startLocation!.toLowerCase())) && // Apply start location filter with partial match
        (_endLocation == null || trip.endLocation.toLowerCase().contains(_endLocation!.toLowerCase())) // Apply end location filter with partial match
      )
      .map((trip) {
        // Log marker creation
        print('Adding marker for trip: ${trip.id} at (${trip.startLat}, ${trip.startLng})');
        // Create marker for each trip
        return Marker(
          // Unique ID for marker
          markerId: MarkerId('trip_${trip.id}'),
          // Marker position
          position: LatLng(trip.startLat, trip.startLng),
          // Red marker for trips
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          // Info window shown when marker is tapped
          infoWindow: InfoWindow(
            // Show route
            title: '${trip.startLocation} → ${trip.endLocation}',
            // Show date and time
            snippet: '${trip.departureTime.day}/${trip.departureTime.month}/${trip.departureTime.year} ${trip.departureTime.hour}:${trip.departureTime.minute}',
            // Handle marker tap
            onTap: () {
              // When marker is tapped, show route and trip details
              setState(() {
                // Create polyline for the route
                _polylines = {
                  // Create polyline
                  Polyline(
                    // Unique ID for polyline
                    polylineId: PolylineId('route_${trip.id}'),
                    // Route points
                    points: [
                      // Start point
                      LatLng(trip.startLat, trip.startLng),
                      // End point
                      LatLng(trip.endLat, trip.endLng),
                    ],
                    // Blue color for route
                    color: Colors.blue,
                    // Route width
                    width: 5,
                  ),
                };
              });
              // Show bottom sheet with trip details
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => TripDetailsScreen(trip: trip),
              );
            },
          ),
        );
      })
      .toSet();

    // Update state with new markers
    setState(() {
      _tripMarkers = markers;
      _markers = {..._tripMarkers, ..._requestMarkers};
    });

    // Show SnackBar if no trips are found and search filters are applied
    if (markers.isEmpty && (_startLocation != null || _endLocation != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Available Trips'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Animate camera to fit all trip markers if any exist
    if (_mapController != null && _tripMarkers.isNotEmpty) {
      try {
        // Delay camera animation slightly to ensure markers are rendered
        Future.delayed(const Duration(milliseconds: 300), () {
          // Calculate bounds to fit all markers
          final bounds = _createLatLngBounds(_tripMarkers.map((m) => m.position).toList());
          // Animate camera to show all markers
          _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        });
      } catch (e) {
        // Log any errors during camera animation
        print('Error animating camera: $e');
      }
    }
  }

  // Method to update request markers on the map
  void _updateRequestMarkers(List<TripRequestModel> requests) {
    // Filter and map requests to markers
    final requestMarkers = requests
      .where((request) => 
        // Only show requests less than 24 hours old
        DateTime.now().difference(request.createdAt).inHours < 24
      )
      .map((request) {
        // Create marker for each request
        return Marker(
          // Unique ID for marker
          markerId: MarkerId('request_${request.id}'),
          // Marker position
          position: LatLng(request.startLat, request.startLng),
          // Green marker for requests
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          // Info window shown when marker is tapped
          infoWindow: InfoWindow(
            // Show route
            title: '${request.startLocation} → ${request.endLocation}',
            // Show date
            snippet: '${request.dateWanted.day}/${request.dateWanted.month}/${request.dateWanted.year}',
            // Handle marker tap
            onTap: () async {
              // Get current user
              final currentUser = AuthService().currentUser;
              // Default requester name
              String requesterName = 'User';
              try {
                // Get requester's name from Firestore
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(request.userId).get();
                // Get user data
                final userData = userDoc.data();
                // Update requester name if available
                if (userData != null) {
                  requesterName = userData['name'] ?? userData['email'] ?? 'User';
                }
              } catch (_) {}
              // Check if widget is still mounted
              if (context.mounted) {
                // Show bottom sheet with request details
                showModalBottomSheet(
                  // Get current context
                  context: context,
                  // Build bottom sheet content
                  builder: (context) {
                    // Return bottom sheet content
                    return Padding(
                      // Add padding around content
                      padding: const EdgeInsets.all(16.0),
                      // Column for vertical layout
                      child: Column(
                        // Use minimum space needed
                        mainAxisSize: MainAxisSize.min,
                        // Align content to start
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Bottom sheet content
                        children: [
                          // Show route
                          Text(
                            // Route text
                            '${request.startLocation} → ${request.endLocation}',
                            // Style for route text
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // Add vertical space
                          const SizedBox(height: 8),
                          // Show date
                          Text('Date: ${request.dateWanted.year}-${request.dateWanted.month.toString().padLeft(2, '0')}-${request.dateWanted.day.toString().padLeft(2, '0')}'),
                          // Show seats wanted
                          Text('Seats Wanted: ${request.seatsWanted}'),
                          // Show requester name
                          Text('Requester: $requesterName'),
                          // Add vertical space
                          const SizedBox(height: 16),
                          // Show offer button if user is logged in
                          if (currentUser != null)
                            // Offer trip button
                            ElevatedButton(
                              // Handle button press
                              onPressed: () async {
                                // Generate chat room ID
                                final chatRoomId = getChatRoomId(currentUser.uid, request.userId);
                                // Create chat room if it doesn't exist
                                await createChatRoomIfNotExists(chatRoomId, currentUser.uid, request.userId);
                                // Check if widget is still mounted
                                if (context.mounted) {
                                  // Navigate to chat screen
                                  Navigator.of(context).push(
                                    // Create route to chat screen
                                    MaterialPageRoute(
                                      // Build chat screen
                                      builder: (context) => ChatRoomScreen(
                                        // Pass chat room ID
                                        chatRoomId: chatRoomId,
                                        // Pass other user's name
                                        otherUserName: requesterName,
                                      ),
                                    ),
                                  );
                                }
                              },
                              // Button text
                              child: const Text('Offer a Trip'),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      }).toSet();

    // Update markers in state
    setState(() {
      // Update request markers
      _requestMarkers = requestMarkers;
      // Combine trip and request markers
      _markers = {..._tripMarkers, ..._requestMarkers};
    });
  }

  // Method to apply location filters
  void _applyFilter() {
    // Update state with filter values
    setState(() {
      // Get start location from controller
      _startLocation = _startLocationController.text.trim();
      // Get end location from controller
      _endLocation = _endLocationController.text.trim();
    });
    // Reload trips to apply the filter
    _tripService.getAllTrips().listen((trips) {
      // Update trip markers with filtered trips
      _updateTripMarkers(trips);
    });
  }

  @override
  // Build the widget
  Widget build(BuildContext context) {
    // Return scaffold with map and search filter
    return Scaffold(
      // Body of the screen
      body: Stack(
        // Stack children
        children: [
          // Google Map widget
          GoogleMap(
            // Initial camera position
            initialCameraPosition: const CameraPosition(
              // Center of the world
              target: LatLng(0, 0),
              // Initial zoom level
              zoom: 2,
            ),
            // Handle map creation
            onMapCreated: (controller) {
              // Store map controller
              _mapController = controller;
            },
            // Show markers on map
            markers: _markers,
            // Show polylines on map
            polylines: _polylines,
          ),
          // Search filter card
          Positioned(
            // Position from top
            top: 16,
            // Position from left
            left: 16,
            // Position from right
            right: 16,
            // Card widget
            child: Card(
              // Card content
              child: Padding(
                // Add padding around content
                padding: const EdgeInsets.all(8.0),
                // Row for horizontal layout
                child: Row(
                  // Row children
                  children: [
                    // Start location input
                    Expanded(
                      // Text field for start location
                      child: TextField(
                        // Controller for start location
                        controller: _startLocationController,
                        // Input decoration
                        decoration: const InputDecoration(
                          // Label text
                          labelText: 'Start',
                          // Prefix icon
                          prefixIcon: Icon(Icons.location_on, color: Colors.red, size: 20),
                          // Content padding
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          // Make field more compact
                          isDense: true,
                        ),
                      ),
                    ),
                    // Add horizontal space
                    const SizedBox(width: 8),
                    // End location input
                    Expanded(
                      // Text field for end location
                      child: TextField(
                        // Controller for end location
                        controller: _endLocationController,
                        // Input decoration
                        decoration: const InputDecoration(
                          // Label text
                          labelText: 'End',
                          // Prefix icon
                          prefixIcon: Icon(Icons.location_on, color: Colors.green, size: 20),
                          // Content padding
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          // Make field more compact
                          isDense: true,
                        ),
                      ),
                    ),
                    // Add horizontal space
                    const SizedBox(width: 8),
                    // Search button
                    ElevatedButton(
                      // Handle button press
                      onPressed: _applyFilter,
                      // Button style
                      style: ElevatedButton.styleFrom(
                        // Button padding
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        // Minimum button size
                        minimumSize: const Size(80, 36),
                      ),
                      // Button text
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create bounds for camera animation
  LatLngBounds _createLatLngBounds(List<LatLng> positions) {
    // Initialize bounds with first position
    double x0 = positions[0].latitude;
    double x1 = positions[0].latitude;
    double y0 = positions[0].longitude;
    double y1 = positions[0].longitude;

    // Update bounds with remaining positions
    for (LatLng latLng in positions.skip(1)) {
      // Update maximum latitude
      if (latLng.latitude > x1) x1 = latLng.latitude;
      // Update minimum latitude
      if (latLng.latitude < x0) x0 = latLng.latitude;
      // Update maximum longitude
      if (latLng.longitude > y1) y1 = latLng.longitude;
      // Update minimum longitude
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    // Return bounds
    return LatLngBounds(
      // Southwest corner
      southwest: LatLng(x0, y0),
      // Northeast corner
      northeast: LatLng(x1, y1),
    );
  }

  // Helper method to generate chat room ID
  String getChatRoomId(String uid1, String uid2) {
    // Sort user IDs
    final sorted = [uid1, uid2]..sort();
    // Join with underscore
    return sorted.join('_');
  }

  // Helper method to create chat room if it doesn't exist
  Future<void> createChatRoomIfNotExists(String chatRoomId, String uid1, String uid2) async {
    // Check if chat room exists
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).get();
    // Create chat room if it doesn't exist
    if (!chatDoc.exists) {
      // Create chat room document
      await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
        // Add participants
        'participants': [uid1, uid2],
        // Add creation time
        'createdAt': DateTime.now().toIso8601String(),
        // Initialize last message
        'lastMessage': '',
        // Initialize last message time
        'lastMessageTime': DateTime.now().toIso8601String(),
      });
    }
  }
}