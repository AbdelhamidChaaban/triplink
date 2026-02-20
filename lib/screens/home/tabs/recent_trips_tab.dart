import 'package:flutter/material.dart'; // Import Flutter material design library
import '../../../models/trip_model.dart'; // Import trip model
import '../../../services/trip_service.dart'; // Import trip service
import 'trip_details_screen.dart'; // Import trip details screen
import '../../../models/trip_request_model.dart'; // Import trip request model
import '../../../services/auth_service.dart'; // Import authentication service
import 'chat_room_screen.dart'; // Import chat room screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

// --- Helper functions (top-level, must be before any class uses them) ---
String getChatRoomId(String uid1, String uid2) { // Get chat room ID
  final sorted = [uid1, uid2]..sort(); // Sort user IDs
  return sorted.join('_'); // Join IDs with underscore
}

Future<void> createChatRoomIfNotExists(String chatRoomId, String uid1, String uid2) async { // Create chat room if it doesn't exist
  final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).get(); // Get chat doc
  if (!chatDoc.exists) { // If not exists
    await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({ // Create chat doc
      'participants': [uid1, uid2], // Participants
      'createdAt': DateTime.now().toIso8601String(), // Created at
      'lastMessage': '', // Last message
      'lastMessageTime': DateTime.now().toIso8601String(), // Last message time
    }); // End of set
  } // End of if
}

class RecentTripsTab extends StatefulWidget { // Define RecentTripsTab widget
  const RecentTripsTab({super.key}); // Constructor

  @override // Override createState method
  State<RecentTripsTab> createState() => _RecentTripsTabState(); // Create state
}

class _RecentTripsTabState extends State<RecentTripsTab> { // Define state for RecentTripsTab
  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return DefaultTabController( // Use tab controller
      length: 2, // Two tabs
      child: Scaffold( // Return Scaffold widget
        appBar: AppBar( // App bar
          title: const Text('Recent Trips'), // App bar title
          bottom: const TabBar( // Tab bar
            tabs: [ // Start tabs list
              Tab(text: 'Available Trips'), // Available Trips tab
              Tab(text: 'Available Requests'), // Available Requests tab
            ], // End tabs list
          ), // End of TabBar
        ), // End of AppBar
        body: TabBarView( // Tab bar view
          children: [ // Start children list
            _AvailableTripsPage(), // Available Trips page
            _AvailableRequestsPage(), // Available Requests page
          ], // End children list
        ), // End of TabBarView
      ), // End of Scaffold
    ); // End of DefaultTabController
  } // End of build method
}

// --- Available Trips Page ---
class _AvailableTripsPage extends StatelessWidget { // Define _AvailableTripsPage widget
  _AvailableTripsPage(); // Constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    final _tripService = TripService(); // Create trip service instance
    final currentUser = AuthService().currentUser; // Get current user
    return StreamBuilder<List<TripModel>>( // Stream all trips
      stream: _tripService.getAllTrips(), // Get all trips
      builder: (context, snapshot) { // Build trip list
        if (snapshot.connectionState == ConnectionState.waiting) { // If loading
          return const Center(child: CircularProgressIndicator()); // Show loading
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) { // If no trips
          return const Center(child: Text('No recent trips found')); // Show no trips
        }
        final now = DateTime.now(); // Get current time
        final trips = snapshot.data!
            .where((trip) => trip.availableSeats > 0 && now.difference(trip.createdAt).inHours < 24)
            .toList(); // Filter trips
        if (trips.isEmpty) { // If no trips after filter
          return const Center(child: Text('No recent trips found')); // Show no trips
        }
        return ListView.builder( // Build trip list
          itemCount: trips.length, // Number of trips
          itemBuilder: (context, index) { // Build each trip
            final trip = trips[index]; // Get trip
            final isOwnTrip = currentUser != null && trip.driverId == currentUser.uid; // Is this my trip?
            return Card( // Trip card
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Card margin
              child: ListTile( // List tile for trip
                title: Text( // Trip route
                  '${trip.startLocation} → ${trip.endLocation}', // Route text
                  style: const TextStyle(fontWeight: FontWeight.bold), // Bold text
                ), // End of Text
                subtitle: Column( // Subtitle column
                  crossAxisAlignment: CrossAxisAlignment.start, // Align start
                  children: [ // Start children list
                    Text('Date: ${trip.departureTime.day}/${trip.departureTime.month}/${trip.departureTime.year}'), // Date
                    Text('Time: ${trip.departureTime.hour}:${trip.departureTime.minute}'), // Time
                    Text('Price: \$${trip.pricePerSeat} per seat'), // Price
                    Text('Available Seats: ${trip.availableSeats}'), // Available seats
                    if (isOwnTrip && trip.status != 'public') // If my trip and not public
                      Padding( // Add padding
                        padding: const EdgeInsets.only(top: 8.0), // Padding value
                        child: ElevatedButton( // Make It Public button
                          onPressed: () async { // On press
                            await FirebaseFirestore.instance
                                .collection('trips')
                                .doc(trip.id)
                                .update({'status': 'public'}); // Update status
                          }, // End of onPressed
                          child: const Text('Make It Public'), // Button text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Button color
                          ), // End of style
                        ), // End of ElevatedButton
                      ), // End of Padding
                  ], // End children list
                ), // End of Column
                trailing: ElevatedButton( // View Details button
                  onPressed: () { // On press
                    Navigator.of(context).push( // Navigate to details
                      MaterialPageRoute( // Create route
                        builder: (context) => TripDetailsScreen(trip: trip), // Build details screen
                      ), // End of MaterialPageRoute
                    ); // End of push
                  }, // End of onPressed
                  child: const Text('View Details'), // Button text
                ), // End of ElevatedButton
              ), // End of ListTile
            ); // End of Card
          }, // End of itemBuilder
        ); // End of ListView.builder
      }, // End of builder
    ); // End of StreamBuilder
  } // End of build method
}

// --- Available Requests Page ---
class _AvailableRequestsPage extends StatelessWidget { // Define _AvailableRequestsPage widget
  _AvailableRequestsPage(); // Constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    final _tripService = TripService(); // Create trip service instance
    final currentUser = AuthService().currentUser; // Get current user
    return StreamBuilder<List<TripRequestModel>>( // Stream all trip requests
      stream: _tripService.getAllTripRequests(), // Get all trip requests
      builder: (context, snapshot) { // Build request list
        if (snapshot.connectionState == ConnectionState.waiting) { // If loading
          return const Center(child: CircularProgressIndicator()); // Show loading
        }
        final requests = snapshot.data ?? []; // Get requests
        if (requests.isEmpty) { // If no requests
          return const Center(child: Text('No trip requests found')); // Show no requests
        }
        return ListView.builder( // Build request list
          itemCount: requests.length, // Number of requests
          itemBuilder: (context, index) { // Build each request
            final req = requests[index]; // Get request
            return Card( // Request card
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Card margin
              child: FutureBuilder<DocumentSnapshot>( // Future builder for requester
                future: FirebaseFirestore.instance.collection('users').doc(req.userId).get(), // Get requester doc
                builder: (context, userSnapshot) { // Build requester info
                  if (!userSnapshot.hasData) { // If no data
                    return ListTile( // List tile for request
                      title: Text('${req.startLocation} → ${req.endLocation}'), // Route text
                      subtitle: Column( // Subtitle column
                        crossAxisAlignment: CrossAxisAlignment.start, // Align start
                        children: [ // Start children list
                          Text('Seats Wanted: ${req.seatsWanted}'), // Seats wanted
                          Text('Date: ${req.dateWanted.year}-${req.dateWanted.month.toString().padLeft(2, '0')}-${req.dateWanted.day.toString().padLeft(2, '0')}'), // Date
                          const Text('Requester: ...'), // Placeholder
                        ], // End children list
                      ), // End of Column
                    ); // End of ListTile
                  }
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?; // Get user data
                  final requesterName = userData != null ? (userData['name'] ?? userData['email'] ?? 'User') : 'User'; // Get requester name
                  return ListTile( // List tile for request
                    title: Text('${req.startLocation} → ${req.endLocation}'), // Route text
                    subtitle: Column( // Subtitle column
                      crossAxisAlignment: CrossAxisAlignment.start, // Align start
                      children: [ // Start children list
                        Text('Seats Wanted: ${req.seatsWanted}'), // Seats wanted
                        Text('Date: ${req.dateWanted.year}-${req.dateWanted.month.toString().padLeft(2, '0')}-${req.dateWanted.day.toString().padLeft(2, '0')}'), // Date
                        Text('Requester: $requesterName'), // Requester name
                      ], // End children list
                    ), // End of Column
                    trailing: (currentUser != null)
                        ? ElevatedButton( // Chat button
                            onPressed: () async { // On press
                              final chatRoomId = getChatRoomId(currentUser.uid, req.userId); // Get chat room ID
                              await createChatRoomIfNotExists(chatRoomId, currentUser.uid, req.userId); // Create chat room if needed
                              if (context.mounted) { // If context is mounted
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatRoomScreen(
                                      chatRoomId: chatRoomId,
                                      otherUserName: requesterName,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Offer a Trip'),
                          )
                        : null,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
} 