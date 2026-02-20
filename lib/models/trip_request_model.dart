// Model representing a trip request in the app
class TripRequestModel {
  final String id; // Unique ID for the request
  final String userId; // ID of the user who made the request
  final String startLocation; // Start location of the requested trip
  final String endLocation; // End location of the requested trip
  final double startLat; // Start location latitude
  final double startLng; // Start location longitude
  final double endLat; // End location latitude
  final double endLng; // End location longitude
  final int seatsWanted; // Number of seats requested
  final DateTime dateWanted; // Date the user wants to travel
  final DateTime createdAt; // When the request was created

  TripRequestModel({
    required this.id, // Required request ID
    required this.userId, // Required user ID
    required this.startLocation, // Required start location
    required this.endLocation, // Required end location
    required this.startLat, // Required start latitude
    required this.startLng, // Required start longitude
    required this.endLat, // Required end latitude
    required this.endLng, // Required end longitude
    required this.seatsWanted, // Required number of seats
    required this.dateWanted, // Required travel date
    required this.createdAt, // Required creation time
  });

  // Factory constructor to create a TripRequestModel from Firestore JSON
  factory TripRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return TripRequestModel(
      id: id, // Use provided ID
      userId: json['userId'] as String, // Parse user ID
      startLocation: json['startLocation'] as String, // Parse start location
      endLocation: json['endLocation'] as String, // Parse end location
      startLat: (json['startLat'] as num?)?.toDouble() ?? 0.0, // Parse start latitude
      startLng: (json['startLng'] as num?)?.toDouble() ?? 0.0, // Parse start longitude
      endLat: (json['endLat'] as num?)?.toDouble() ?? 0.0, // Parse end latitude
      endLng: (json['endLng'] as num?)?.toDouble() ?? 0.0, // Parse end longitude
      seatsWanted: json['seatsWanted'] as int, // Parse seats wanted
      dateWanted: DateTime.parse(json['dateWanted'] as String), // Parse travel date
      createdAt: DateTime.parse(json['createdAt'] as String), // Parse creation time
    );
  }

  // Convert this model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // User ID
      'startLocation': startLocation, // Start location
      'endLocation': endLocation, // End location
      'startLat': startLat, // Start latitude
      'startLng': startLng, // Start longitude
      'endLat': endLat, // End latitude
      'endLng': endLng, // End longitude
      'seatsWanted': seatsWanted, // Seats wanted
      'dateWanted': dateWanted.toIso8601String(), // Travel date as ISO string
      'createdAt': createdAt.toIso8601String(), // Creation time as ISO string
    };
  }
} 