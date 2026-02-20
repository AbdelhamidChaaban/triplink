import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../services/auth_service.dart';
import '../models/trip_request_model.dart';

// Service class for all trip and trip request related Firestore operations
// Handles CRUD (Create, Read, Update, Delete) operations for trips, trip requests, and notifications
class TripService {
  // Initialize Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new trip in Firestore
  // Parameters:
  //   - trip: TripModel object containing trip details
  // Returns: The created TripModel
  Future<TripModel> createTrip(TripModel trip) async {
    try {
      // Store trip data in Firestore using trip ID as document ID
      await _firestore.collection('trips').doc(trip.id).set(trip.toJson());
      return trip;
    } catch (e) {
      // Throw exception if trip creation fails
      throw Exception('Failed to create trip: $e');
    }
  }

  // Get a specific trip by its ID from Firestore
  // Parameters:
  //   - tripId: String ID of the trip to retrieve
  // Returns: TripModel object containing trip details
  Future<TripModel> getTrip(String tripId) async {
    try {
      // Fetch trip document from Firestore
      final DocumentSnapshot doc = await _firestore.collection('trips').doc(tripId).get();
      // Convert Firestore data to TripModel
      return TripModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Throw exception if trip retrieval fails
      throw Exception('Failed to get trip: $e');
    }
  }

  // Update an existing trip in Firestore
  // Parameters:
  //   - trip: TripModel object containing updated trip details
  Future<void> updateTrip(TripModel trip) async {
    try {
      // Update trip document in Firestore
      await _firestore.collection('trips').doc(trip.id).update(trip.toJson());
    } catch (e) {
      // Throw exception if trip update fails
      throw Exception('Failed to update trip: $e');
    }
  }

  // Delete a trip from Firestore
  // Parameters:
  //   - tripId: String ID of the trip to delete
  Future<void> deleteTrip(String tripId) async {
    try {
      // Delete trip document from Firestore
      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e) {
      // Throw exception if trip deletion fails
      throw Exception('Failed to delete trip: $e');
    }
  }

  // Search for trips based on specified criteria
  // Parameters:
  //   - startLocation: Optional start location filter
  //   - endLocation: Optional end location filter
  //   - date: Optional date filter
  // Returns: Stream of filtered TripModel list
  Stream<List<TripModel>> searchTrips({
    String? startLocation,
    String? endLocation,
    DateTime? date,
  }) {
    try {
      // Start with base query for scheduled trips
      Query query = _firestore.collection('trips')
          .where('status', isEqualTo: 'scheduled');

      // Add start location filter if provided
      if (startLocation != null) {
        query = query.where('startLocation', isEqualTo: startLocation);
      }
      // Add end location filter if provided
      if (endLocation != null) {
        query = query.where('endLocation', isEqualTo: endLocation);
      }
      // Add date filter if provided
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where('departureTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
            .where('departureTime', isLessThan: endOfDay.toIso8601String());
      }

      // Return stream of filtered trips
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TripModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      // Throw exception if search fails
      throw Exception('Failed to search trips: $e');
    }
  }

  // Get trips for a specific user
  // Parameters:
  //   - userId: String ID of the user
  //   - asDriver: Boolean indicating if user is driver (true) or passenger (false)
  // Returns: Stream of TripModel list
  Stream<List<TripModel>> getUserTrips(String userId, {bool asDriver = false}) {
    try {
      // Query trips based on user role
      final query = _firestore.collection('trips').where(
        asDriver ? 'driverId' : 'passengerIds',
        isEqualTo: asDriver ? userId : [userId],
      );

      // Return stream of user's trips
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TripModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      // Throw exception if retrieval fails
      throw Exception('Failed to get user trips: $e');
    }
  }

  // Add a passenger to a trip
  // Parameters:
  //   - tripId: String ID of the trip
  //   - passengerId: String ID of the passenger to add
  Future<void> addPassenger(String tripId, String passengerId) async {
    try {
      // Update trip document to add passenger and decrease available seats
      await _firestore.collection('trips').doc(tripId).update({
        'passengerIds': FieldValue.arrayUnion([passengerId]),
        'availableSeats': FieldValue.increment(-1),
      });
    } catch (e) {
      // Throw exception if adding passenger fails
      throw Exception('Failed to add passenger: $e');
    }
  }

  // Remove a passenger from a trip
  // Parameters:
  //   - tripId: String ID of the trip
  //   - passengerId: String ID of the passenger to remove
  Future<void> removePassenger(String tripId, String passengerId) async {
    try {
      // Update trip document to remove passenger and increase available seats
      await _firestore.collection('trips').doc(tripId).update({
        'passengerIds': FieldValue.arrayRemove([passengerId]),
        'availableSeats': FieldValue.increment(1),
      });
    } catch (e) {
      // Throw exception if removing passenger fails
      throw Exception('Failed to remove passenger: $e');
    }
  }

  // Book a trip for a user
  // Parameters:
  //   - trip: TripModel of the trip to book
  //   - numberOfSeats: Number of seats to book
  // Returns: Boolean indicating success or failure
  Future<bool> bookTrip(TripModel trip, int numberOfSeats) async {
    print('TripService.bookTrip called');
    try {
      // Get current user
      final currentUser = AuthService().currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      // Get trip document
      final tripRef = _firestore.collection('trips').doc(trip.id);
      final tripDoc = await tripRef.get();

      // Check if trip exists
      if (!tripDoc.exists) throw Exception('Trip not found');
      final currentTrip = TripModel.fromJson(tripDoc.data() as Map<String, dynamic>);

      // Check if enough seats are available
      if (currentTrip.availableSeats < numberOfSeats) {
        throw Exception('Not enough available seats');
      }

      // Update trip with new passenger and seat count
      await tripRef.update({
        'availableSeats': currentTrip.availableSeats - numberOfSeats,
        'passengerIds': FieldValue.arrayUnion([currentUser.uid]),
      });

      print('Booking successful: seats updated and passenger added.');
      return true;
    } catch (e) {
      print('Booking failed: $e');
      return false;
    }
  }

  // Get all trips from Firestore
  // Returns: Stream of all TripModel list
  Stream<List<TripModel>> getAllTrips() {
    try {
      // Return stream of all trips
      return _firestore.collection('trips').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TripModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      // Throw exception if retrieval fails
      throw Exception('Failed to get all trips: $e');
    }
  }

  // Create a notification for a user
  // Parameters:
  //   - userId: String ID of the user to notify
  //   - message: String message content
  //   - passengerId: Optional passenger ID
  //   - pickupLat: Optional pickup latitude
  //   - pickupLng: Optional pickup longitude
  //   - dropoffLat: Optional dropoff latitude
  //   - dropoffLng: Optional dropoff longitude
  Future<void> createNotification({
    required String userId,
    required String message,
    String? passengerId,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng
  }) async {
    try {
      // Generate unique notification ID using current timestamp
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create notification data structure with required and optional fields
      // The notification object contains:
      // - id: Unique identifier for the notification
      // - userId: ID of the user who will receive the notification
      // - message: The notification content/message
      // - createdAt: Timestamp of when the notification was created
      // - isRead: Boolean flag indicating if the notification has been read
      // - Optional fields that are only included if they are not null:
      //   * passengerId: ID of the passenger (if notification is passenger-related)
      //   * pickupLat/Lng: Pickup location coordinates (if location is relevant)
      //   * dropoffLat/Lng: Dropoff location coordinates (if location is relevant)
      final notification = {
        'id': notificationId,
        'userId': userId,
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
        // Only include passengerId if it's provided
        if (passengerId != null) 'passengerId': passengerId,
        // Only include pickup coordinates if they're provided
        if (pickupLat != null) 'pickupLat': pickupLat,
        if (pickupLng != null) 'pickupLng': pickupLng,
        // Only include dropoff coordinates if they're provided
        if (dropoffLat != null) 'dropoffLat': dropoffLat,
        if (dropoffLng != null) 'dropoffLng': dropoffLng,
      };

      // Store the notification document in the 'notifications' collection
      // Using the generated notificationId as the document ID
      await _firestore.collection('notifications').doc(notificationId).set(notification);
      
      // Update the user's document in the 'users' collection
      // Add the notification ID to the user's notificationIds array
      // This creates a reference to the notification in the user's document
      await _firestore.collection('users').doc(userId).update({
        'notificationIds': FieldValue.arrayUnion([notificationId])
      });
      
      // Log successful notification creation
      print('Notification created for user $userId');
    } catch (e) {
      // Log any errors that occur during notification creation
      print('Error creating notification: $e');
      // Throw an exception with the error details
      throw Exception('Failed to create notification: $e');
    }
  }

  // Create a new trip request
  // Parameters:
  //   - request: TripRequestModel object containing request details
  Future<void> createTripRequest(TripRequestModel request) async {
    try {
      print('Creating trip request in Firestore: ${request.toJson()}');
      // Store request in Firestore
      await _firestore.collection('tripRequests').doc(request.id).set(request.toJson());
      print('Trip request created successfully');
    } catch (e) {
      print('Error creating trip request: $e');
      throw Exception('Failed to create trip request: $e');
    }
  }

  // Get all trip requests from Firestore
  // Returns: Stream of TripRequestModel list, ordered by date
  Stream<List<TripRequestModel>> getAllTripRequests() {
    // Return stream of all requests, ordered by date
    return _firestore
        .collection('tripRequests')
        .orderBy('dateWanted', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripRequestModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get trip requests for a specific user
  // Parameters:
  //   - userId: String ID of the user
  // Returns: Stream of TripRequestModel list
  Stream<List<TripRequestModel>> getUserTripRequests(String userId) {
    print('Getting trip requests for user: $userId');
    // Return stream of user's requests, ordered by date
    return _firestore
        .collection('tripRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('dateWanted', descending: false)
        .snapshots()
        .map((snapshot) {
          print('Received ${snapshot.docs.length} requests from Firestore');
          return snapshot.docs
              .map((doc) => TripRequestModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
} 