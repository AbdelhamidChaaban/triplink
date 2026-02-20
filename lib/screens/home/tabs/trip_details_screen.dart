// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import trip model for trip data structure
import '../../../models/trip_model.dart';
// Import trip service for managing trip data operations
import '../../../services/trip_service.dart';
// Import book trip form screen for booking trips
import 'book_trip_form_screen.dart';
// Import auth service for user authentication
import '../../../services/auth_service.dart';
// Import Cloud Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Import map viewer screen for viewing routes
import '../../maps/map_viewer_screen.dart';
// Import Google Maps Flutter package for map functionality
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Define TripDetailsScreen as a stateful widget for displaying trip details
class TripDetailsScreen extends StatefulWidget {
  // Trip model instance to display
  final TripModel trip;

  // Constructor for TripDetailsScreen
  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  // Create state for TripDetailsScreen
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

// Define the state class for TripDetailsScreen
class _TripDetailsScreenState extends State<TripDetailsScreen> {
  // Create instance of trip service for managing trips
  final _tripService = TripService();
  // Loading state flag
  bool _isLoading = false;
  // Number of seats selected for booking
  final int _selectedSeats = 1;

  // Method to view trip route on map
  void _viewRoute(TripModel trip) {
    // Navigate to map viewer screen
    Navigator.push(
      // Get current context
      context,
      // Create route to map viewer
      MaterialPageRoute(
        // Build map viewer screen
        builder: (context) => MapViewerScreen(
          // Pass start location coordinates
          startLocation: LatLng(trip.startLat, trip.startLng),
          // Pass end location coordinates
          endLocation: LatLng(trip.endLat, trip.endLng),
          // Pass start location address
          startAddress: trip.startLocation,
          // Pass end location address
          endAddress: trip.endLocation,
        ),
      ),
    );
  }

  // Method to book trip with user information
  Future<void> _bookTripWithUserInfo(Map<String, String> userInfo, TripModel trip) async {
    // Log booking attempt
    print('TripDetailsScreen _bookTripWithUserInfo called');
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Parse selected seats from user info
      final selectedSeats = int.parse(userInfo['seats'] ?? '1');
      
      // Get current user and user details in parallel with booking
      final currentUser = AuthService().currentUser;
      final userDocFuture = currentUser != null 
          ? FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get()
          : null;

      // Attempt to book trip
      final success = await _tripService.bookTrip(trip, selectedSeats);

      // Handle booking failure
      if (!success) {
        // Log booking failure
        print('Booking failed, not sending notification.');
        // Show error message if widget is mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking failed: Not enough available seats.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Do not proceed or pop
      }
      // Log booking success
      print('Booking succeeded, preparing to send notification.');

      // Get user details if we have a user
      String passengerName = 'Passenger';
      String passengerPhone = '';
      if (userDocFuture != null) {
        final userDoc = await userDocFuture;
        final userData = userDoc.data();
        if (userData != null) {
          passengerName = userData['name'] ?? 'Passenger';
          passengerPhone = userData['phoneNumber'] ?? '';
        }
      }

      // Create notification for driver
      await _tripService.createNotification(
        // Driver's user ID
        userId: trip.driverId,
        // Notification message
        message:
            '$passengerName has booked $selectedSeats seat(s) on your trip from ${trip.startLocation} to ${trip.endLocation}.\n'
            'Phone: $passengerPhone\n'
            'Pickup: ${userInfo['pickup']}\n'
            'Dropoff: ${userInfo['dropoff']}',
        // Passenger's user ID
        passengerId: currentUser?.uid,
        // Parse pickup latitude
        pickupLat: userInfo['pickupLat'] != null ? double.tryParse(userInfo['pickupLat']!) : null,
        // Parse pickup longitude
        pickupLng: userInfo['pickupLng'] != null ? double.tryParse(userInfo['pickupLng']!) : null,
        // Parse dropoff latitude
        dropoffLat: userInfo['dropoffLat'] != null ? double.tryParse(userInfo['dropoffLat']!) : null,
        // Parse dropoff longitude
        dropoffLng: userInfo['dropoffLng'] != null ? double.tryParse(userInfo['dropoffLng']!) : null,
      );
      // Log notification success
      print('Notification sent to driver.');

      // Show success message if widget is mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      // Log error
      print('Error during booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred during booking.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset loading state if widget is mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  // Build the widget
  Widget build(BuildContext context) {
    // Return stream builder to listen for trip updates
    return StreamBuilder<DocumentSnapshot>(
      // Stream of trip document updates
      stream: FirebaseFirestore.instance.collection('trips').doc(widget.trip.id).snapshots(),
      // Build function for stream builder
      builder: (context, snapshot) {
        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Show error if trip not found
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Trip not found', style: TextStyle(color: Colors.white))),
            backgroundColor: Colors.black,
          );
        }
        // Get trip data from snapshot
        final tripData = snapshot.data!.data() as Map<String, dynamic>?;
        // Show error if trip data is missing
        if (tripData == null) {
          return const Scaffold(
            body: Center(child: Text('Trip data is missing', style: TextStyle(color: Colors.white))),
            backgroundColor: Colors.black,
          );
        }
        // Create trip model from data
        final trip = TripModel.fromJson(tripData);
        // Return scaffold with trip details
        return Scaffold(
          // App bar with title and map button
          appBar: AppBar(
            title: const Text('Trip Details'),
            actions: [
              // Map button to view route
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _viewRoute(trip),
                tooltip: 'View Route',
              ),
            ],
          ),
          // Scrollable body
          body: SingleChildScrollView(
            // Add padding around content
            padding: const EdgeInsets.all(16),
            // Column for vertical layout
            child: Column(
              // Align content to start
              crossAxisAlignment: CrossAxisAlignment.start,
              // Column children
              children: [
                // Route card
                Card(
                  // Card content
                  child: Padding(
                    // Add padding around content
                    padding: const EdgeInsets.all(16),
                    // Column for vertical layout
                    child: Column(
                      // Align content to start
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Column children
                      children: [
                        // Start location row
                        Row(
                          children: [
                            // Start location icon
                            const Icon(Icons.location_on, color: Colors.red),
                            // Add horizontal space
                            const SizedBox(width: 8),
                            // Start location text
                            Expanded(
                              child: Text(
                                trip.startLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Add vertical space
                        const SizedBox(height: 16),
                        // End location row
                        Row(
                          children: [
                            // End location icon
                            const Icon(Icons.location_on, color: Colors.green),
                            // Add horizontal space
                            const SizedBox(width: 8),
                            // End location text
                            Expanded(
                              child: Text(
                                trip.endLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Add vertical space
                const SizedBox(height: 16),
                // Trip details card
                Card(
                  // Card content
                  child: Padding(
                    // Add padding around content
                    padding: const EdgeInsets.all(16),
                    // Column for vertical layout
                    child: Column(
                      // Align content to start
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Column children
                      children: [
                        // Trip details title
                        Text(
                          'Trip Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        // Add vertical space
                        const SizedBox(height: 16),
                        // Date row
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Date',
                          '${trip.departureTime.day}/${trip.departureTime.month}/${trip.departureTime.year}',
                        ),
                        // Add vertical space
                        const SizedBox(height: 8),
                        // Time row
                        _buildDetailRow(
                          Icons.access_time,
                          'Time',
                          '${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}',
                        ),
                        // Add vertical space
                        const SizedBox(height: 8),
                        // Price row
                        _buildDetailRow(
                          Icons.attach_money,
                          'Price',
                          '\$${trip.price.toStringAsFixed(2)}',
                        ),
                        // Add vertical space
                        const SizedBox(height: 8),
                        // Available seats row
                        _buildDetailRow(
                          Icons.event_seat,
                          'Available Seats',
                          trip.availableSeats.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Show notes if available
                if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                  // Add vertical space
                  const SizedBox(height: 16),
                  // Notes card
                  Card(
                    // Card content
                    child: Padding(
                      // Add padding around content
                      padding: const EdgeInsets.all(16),
                      // Column for vertical layout
                      child: Column(
                        // Align content to start
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Column children
                        children: [
                          // Notes title
                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          // Add vertical space
                          const SizedBox(height: 8),
                          // Notes text
                          Text(trip.notes!),
                        ],
                      ),
                    ),
                  ),
                ],
                // Add vertical space
                const SizedBox(height: 24),
                // Show book button if seats are available
                if (trip.availableSeats > 0)
                  // Book trip button
                  ElevatedButton(
                    // Handle button press
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Navigate to booking form
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookTripFormScreen(
                                  trip: trip,
                                  selectedSeats: _selectedSeats,
                                  onBook: (userInfo) => _bookTripWithUserInfo(userInfo, trip),
                                ),
                              ),
                            );
                          },
                    // Button style
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    // Button content
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Book Trip'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build detail row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    // Return row with icon, label, and value
    return Row(
      children: [
        // Icon
        Icon(icon, size: 20),
        // Add horizontal space
        const SizedBox(width: 8),
        // Label
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add horizontal space
        const SizedBox(width: 8),
        // Value
        Text(value),
      ],
    );
  }
}