// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import service for handling trip-related operations
import '../../../services/trip_service.dart';
// Import model class for trip data structure
import '../../../models/trip_model.dart';
// Import service for handling authentication
import '../../../services/auth_service.dart';
// Import screen for displaying trip details
import '../../../screens/home/tabs/trip_details_screen.dart';
// Import model class for trip request data structure
import '../../../models/trip_request_model.dart';
// Import screen for adding new trips
import '../add_trip_screen.dart';
// Import screen for creating trip requests
import 'create_trip_request_screen.dart';
// Import Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';

// Main widget for displaying user's trips and requests
class MyTripsTab extends StatefulWidget {
  const MyTripsTab({super.key});

  @override
  State<MyTripsTab> createState() => _MyTripsTabState();
}

class _MyTripsTabState extends State<MyTripsTab> {
  // Initialize trip service for database operations
  final _tripService = TripService();
  // Initialize auth service for user authentication
  final _authService = AuthService();
  // Boolean flag to track loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Get current user's ID from auth service
    final userId = _authService.currentUser?.uid;
    // Create a tab controller with 2 tabs
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // App bar with title and tab bar
        appBar: AppBar(
          title: const Text('My Trips'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Trips'),
              Tab(text: 'My Requests'),
            ],
          ),
        ),
        // Tab view containing both tabs
        body: TabBarView(
          children: [
            // First tab: My Trips
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      Column(
                        children: [
                          // Header section with title
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('My Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          // List of trips
                          Expanded(
                            child: StreamBuilder<List<TripModel>>(
                              // Stream of user's trips from Firestore
                              stream: userId != null ? _tripService.getUserTrips(userId, asDriver: true) : null,
                              builder: (context, snapshot) {
                                // Show loading indicator while waiting for data
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                // Show message if no trips found
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text('No trips found'));
                                }
                                // Filter trips to show only active ones
                                final trips = snapshot.data!
                                    .where((trip) => trip.availableSeats > 0 && DateTime.now().difference(trip.createdAt).inHours < 24)
                                    .toList();
                                if (trips.isEmpty) {
                                  return const Center(child: Text('No trips found'));
                                }
                                // Build list of trip cards
                                return ListView.builder(
                                  itemCount: trips.length,
                                  itemBuilder: (context, index) {
                                    final trip = trips[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: ListTile(
                                        // Display trip route
                                        title: Text(
                                          '${trip.startLocation} → ${trip.endLocation}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        // Display trip details
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Date: ${trip.departureTime.day}/${trip.departureTime.month}/${trip.departureTime.year}'),
                                            Text('Time: ${trip.departureTime.hour}:${trip.departureTime.minute}'),
                                            Text('Price: \$${trip.pricePerSeat} per seat'),
                                            Text('Available Seats: ${trip.availableSeats}'),
                                            // Show "Make Public" button for non-public trips
                                            if (trip.status != 'public')
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: SizedBox(
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      try {
                                                        // Update trip status to public in Firestore
                                                        await FirebaseFirestore.instance
                                                          .collection('trips')
                                                          .doc(trip.id)
                                                          .update({'status': 'public'});
                                                      } catch (e) {
                                                        // Show error message if update fails
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error making trip public: $e')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: const Text('Make It Public'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // View details button
                                        trailing: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => TripDetailsScreen(trip: trip),
                                              ),
                                            );
                                          },
                                          child: const Text('View Details'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // Floating action button to add new trip
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: FloatingActionButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddTripScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add),
                          tooltip: 'Add Trip',
                        ),
                      ),
                    ],
                  ),
            // Second tab: My Requests
            userId == null
                ? const Center(child: Text('Not logged in'))
                : _MyRequestsTab(userId: userId),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying user's trip requests
class _MyRequestsTab extends StatefulWidget {
  final String userId;
  const _MyRequestsTab({required this.userId});

  @override
  State<_MyRequestsTab> createState() => _MyRequestsTabState();
}

class _MyRequestsTabState extends State<_MyRequestsTab> {
  // Initialize trip service
  final _tripService = TripService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('My Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // List of requests
            Expanded(
              child: StreamBuilder<List<TripRequestModel>>(
                // Stream of user's trip requests
                stream: _tripService.getUserTripRequests(widget.userId),
                builder: (context, snapshot) {
                  // Show error if any
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Show loading indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Get requests or empty list
                  final requests = snapshot.data ?? [];
                  if (requests.isEmpty) {
                    return const Center(child: Text('No trip requests found'));
                  }
                  // Build list of request cards
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: ListTile(
                          // Display request route
                          title: Text(
                            '${req.startLocation} → ${req.endLocation}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Display request details
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seats Wanted: ${req.seatsWanted}'),
                              Text('Date: ${req.dateWanted.year}-${req.dateWanted.month.toString().padLeft(2, '0')}-${req.dateWanted.day.toString().padLeft(2, '0')}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // Add request button
        Positioned(
          bottom: 24,
          right: 24,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 6,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTripRequestScreen(),
                  ),
                );
              },
              child: const Text('+', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}