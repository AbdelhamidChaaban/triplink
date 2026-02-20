// Model representing a user in the app
// Contains user profile information and roles
class UserModel {
  final String id; // Unique identifier for the user
  final String name; // User's full name
  final String email; // User's email address
  final String? phoneNumber; // Optional: user's phone number
  final double rating; // User's rating (default: 0.0)
  final int totalTrips; // Total number of trips taken (default: 0)
  final bool isDriver; // Whether the user is a driver (default: false)
  final List<String>? carDetails; // Optional: details about the user's car (if driver)
  final List<String>? reviews; // Optional: list of review IDs
  final DateTime createdAt; // When the user account was created

  UserModel({
    required this.id, // Required user ID
    required this.name, // Required user name
    required this.email, // Required user email
    this.phoneNumber, // Optional phone number
    this.rating = 0.0, // Default rating
    this.totalTrips = 0, // Default total trips
    this.isDriver = false, // Default isDriver status
    this.carDetails, // Optional car details
    this.reviews, // Optional reviews
    required this.createdAt, // Required creation time
  });

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String, // Parse user ID
      name: json['name'] as String, // Parse user name
      email: json['email'] as String, // Parse user email
      phoneNumber: json['phoneNumber'] as String?, // Parse optional phone number
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // Parse rating
      totalTrips: json['totalTrips'] as int? ?? 0, // Parse total trips
      isDriver: json['isDriver'] as bool? ?? false, // Parse isDriver status
      carDetails: (json['carDetails'] as List<dynamic>?)?.cast<String>(), // Parse car details
      reviews: (json['reviews'] as List<dynamic>?)?.cast<String>(), // Parse reviews
      createdAt: DateTime.parse(json['createdAt'] as String), // Parse creation time
    );
  }

  // Convert the UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // User ID
      'name': name, // User name
      'email': email, // User email
      'phoneNumber': phoneNumber, // Phone number
      'rating': rating, // Rating
      'totalTrips': totalTrips, // Total trips
      'isDriver': isDriver, // Is driver status
      'carDetails': carDetails, // Car details
      'reviews': reviews, // Reviews
      'createdAt': createdAt.toIso8601String(), // Creation time as ISO string
    };
  }

  // Create a copy of the UserModel with optional new values
  UserModel copyWith({
    String? id, // Optional new user ID
    String? name, // Optional new user name
    String? email, // Optional new user email
    String? phoneNumber, // Optional new phone number
    double? rating, // Optional new rating
    int? totalTrips, // Optional new total trips
    bool? isDriver, // Optional new isDriver status
    List<String>? carDetails, // Optional new car details
    List<String>? reviews, // Optional new reviews
    DateTime? createdAt, // Optional new creation time
  }) {
    return UserModel(
      id: id ?? this.id, // Use new or existing user ID
      name: name ?? this.name, // Use new or existing user name
      email: email ?? this.email, // Use new or existing user email
      phoneNumber: phoneNumber ?? this.phoneNumber, // Use new or existing phone number
      rating: rating ?? this.rating, // Use new or existing rating
      totalTrips: totalTrips ?? this.totalTrips, // Use new or existing total trips
      isDriver: isDriver ?? this.isDriver, // Use new or existing isDriver status
      carDetails: carDetails ?? this.carDetails, // Use new or existing car details
      reviews: reviews ?? this.reviews, // Use new or existing reviews
      createdAt: createdAt ?? this.createdAt, // Use new or existing creation time
    );
  }
} 