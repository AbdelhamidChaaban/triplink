// Model representing a trip in the app
// Contains trip details, driver, passengers, and status
// Used for both available trips and user trips
class TripModel {
  final String id; // Unique identifier for the trip
  final String driverId; // ID of the driver
  final List<String> passengerIds; // List of passenger user IDs
  final String startLocation; // Name/address of the start location
  final String endLocation; // Name/address of the end location
  final double startLat; // Latitude of the start location
  final double startLng; // Longitude of the start location
  final double endLat; // Latitude of the end location
  final double endLng; // Longitude of the end location
  final double price; // Total price for the trip
  final int availableSeats; // Number of available seats
  final double pricePerSeat; // Price per seat
  final String status; // 'scheduled', 'in-progress', 'completed', 'cancelled'
  final Map<String, double>? pickupPoints; // Optional: pickup points for passengers
  final String? notes; // Optional: notes about the trip
  final DateTime createdAt; // When the trip was created
  final String driverName; // Name of the driver
  final double driverRating; // Driver's rating
  final String? driverPhoneNumber; // Optional: driver's phone number
  final DateTime departureTime; // Scheduled departure time

  TripModel({
    required this.id, // Required trip ID
    required this.driverId, // Required driver ID
    required this.passengerIds, // Required passenger IDs
    required this.startLocation, // Required start location name
    required this.endLocation, // Required end location name
    required this.startLat, // Required start latitude
    required this.startLng, // Required start longitude
    required this.endLat, // Required end latitude
    required this.endLng, // Required end longitude
    required this.price, // Required total price
    required this.availableSeats, // Required available seats
    required this.pricePerSeat, // Required price per seat
    required this.status, // Required status
    this.pickupPoints, // Optional pickup points
    this.notes, // Optional notes
    required this.createdAt, // Required creation time
    required this.driverName, // Required driver name
    required this.driverRating, // Required driver rating
    this.driverPhoneNumber, // Optional driver phone number
    required this.departureTime, // Required departure time
  });

  // Factory constructor to create a TripModel from a JSON map
  factory TripModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue; // Return default if null
      if (value is num) return value.toDouble(); // Convert num to double
      return double.tryParse(value.toString()) ?? defaultValue; // Try parsing string
    }
    int _toInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue; // Return default if null
      if (value is int) return value; // Return int if already int
      return int.tryParse(value.toString()) ?? defaultValue; // Try parsing string
    }
    return TripModel(
      id: json['id'] as String, // Parse trip ID
      driverId: json['driverId'] as String, // Parse driver ID
      passengerIds: (json['passengerIds'] as List<dynamic>?)?.cast<String>() ?? [], // Parse passenger IDs
      startLocation: json['startLocation'] as String? ?? '', // Parse start location
      endLocation: json['endLocation'] as String? ?? '', // Parse end location
      startLat: _toDouble(json['startLat']), // Parse start latitude
      startLng: _toDouble(json['startLng']), // Parse start longitude
      endLat: _toDouble(json['endLat']), // Parse end latitude
      endLng: _toDouble(json['endLng']), // Parse end longitude
      price: _toDouble(json['price']), // Parse price
      availableSeats: _toInt(json['availableSeats']), // Parse available seats
      pricePerSeat: _toDouble(json['pricePerSeat']), // Parse price per seat
      status: json['status'] as String? ?? 'scheduled', // Parse status
      pickupPoints: (json['pickupPoints'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, _toDouble(value)), // Parse pickup points
      ),
      notes: json['notes'] as String?, // Parse notes
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(), // Parse creation time
      driverName: json['driverName'] as String? ?? '', // Parse driver name
      driverRating: _toDouble(json['driverRating'], 5.0), // Parse driver rating
      driverPhoneNumber: json['driverPhoneNumber'] as String?, // Parse driver phone number
      departureTime: DateTime.tryParse(json['departureTime'] as String? ?? '') ?? DateTime.now(), // Parse departure time
    );
  }

  // Convert the TripModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Trip ID
      'driverId': driverId, // Driver ID
      'passengerIds': passengerIds, // Passenger IDs
      'startLocation': startLocation, // Start location
      'endLocation': endLocation, // End location
      'startLat': startLat, // Start latitude
      'startLng': startLng, // Start longitude
      'endLat': endLat, // End latitude
      'endLng': endLng, // End longitude
      'price': price, // Price
      'availableSeats': availableSeats, // Available seats
      'pricePerSeat': pricePerSeat, // Price per seat
      'status': status, // Status
      'pickupPoints': pickupPoints, // Pickup points
      'notes': notes, // Notes
      'createdAt': createdAt.toIso8601String(), // Creation time as ISO string
      'driverName': driverName, // Driver name
      'driverRating': driverRating, // Driver rating
      'driverPhoneNumber': driverPhoneNumber, // Driver phone number
      'departureTime': departureTime.toIso8601String(), // Departure time as ISO string
    };
  }

  // Create a copy of the TripModel with optional new values
  TripModel copyWith({
    String? id, // Optional new trip ID
    String? driverId, // Optional new driver ID
    List<String>? passengerIds, // Optional new passenger IDs
    String? startLocation, // Optional new start location
    String? endLocation, // Optional new end location
    double? startLat, // Optional new start latitude
    double? startLng, // Optional new start longitude
    double? endLat, // Optional new end latitude
    double? endLng, // Optional new end longitude
    double? price, // Optional new price
    int? availableSeats, // Optional new available seats
    double? pricePerSeat, // Optional new price per seat
    String? status, // Optional new status
    Map<String, double>? pickupPoints, // Optional new pickup points
    String? notes, // Optional new notes
    DateTime? createdAt, // Optional new creation time
    String? driverName, // Optional new driver name
    double? driverRating, // Optional new driver rating
    String? driverPhoneNumber, // Optional new driver phone number
    DateTime? departureTime, // Optional new departure time
  }) {
    return TripModel(
      id: id ?? this.id, // Use new or existing trip ID
      driverId: driverId ?? this.driverId, // Use new or existing driver ID
      passengerIds: passengerIds ?? this.passengerIds, // Use new or existing passenger IDs
      startLocation: startLocation ?? this.startLocation, // Use new or existing start location
      endLocation: endLocation ?? this.endLocation, // Use new or existing end location
      startLat: startLat ?? this.startLat, // Use new or existing start latitude
      startLng: startLng ?? this.startLng, // Use new or existing start longitude
      endLat: endLat ?? this.endLat, // Use new or existing end latitude
      endLng: endLng ?? this.endLng, // Use new or existing end longitude
      price: price ?? this.price, // Use new or existing price
      availableSeats: availableSeats ?? this.availableSeats, // Use new or existing available seats
      pricePerSeat: pricePerSeat ?? this.pricePerSeat, // Use new or existing price per seat
      status: status ?? this.status, // Use new or existing status
      pickupPoints: pickupPoints ?? this.pickupPoints, // Use new or existing pickup points
      notes: notes ?? this.notes, // Use new or existing notes
      createdAt: createdAt ?? this.createdAt, // Use new or existing creation time
      driverName: driverName ?? this.driverName, // Use new or existing driver name
      driverRating: driverRating ?? this.driverRating, // Use new or existing driver rating
      driverPhoneNumber: driverPhoneNumber ?? this.driverPhoneNumber, // Use new or existing driver phone number
      departureTime: departureTime ?? this.departureTime, // Use new or existing departure time
    );
  }
} 