// Model representing a notification in the app
// Used for user notifications about trips, requests, etc.
class NotificationModel {
  // Unique identifier for the notification
  final String id;
  // The user to notify (driver)
  final String userId;
  // The notification message to display
  final String message;
  // When the notification was created
  final DateTime createdAt;
  // Optional: latitude of the pickup location (if relevant)
  final double? pickupLat;
  // Optional: longitude of the pickup location (if relevant)
  final double? pickupLng;
  // Optional: latitude of the dropoff location (if relevant)
  final double? dropoffLat;
  // Optional: longitude of the dropoff location (if relevant)
  final double? dropoffLng;

  // Constructor for NotificationModel
  NotificationModel({
    required this.id, // Required notification ID
    required this.userId, // Required user ID
    required this.message, // Required message
    required this.createdAt, // Required creation time
    this.pickupLat, // Optional pickup latitude
    this.pickupLng, // Optional pickup longitude
    this.dropoffLat, // Optional dropoff latitude
    this.dropoffLng, // Optional dropoff longitude
  });

  // Factory constructor to create a NotificationModel from a JSON map
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String, // Parse notification ID
      userId: json['userId'] as String, // Parse user ID
      message: json['message'] as String, // Parse message
      createdAt: DateTime.parse(json['createdAt'] as String), // Parse creation time
      pickupLat: (json['pickupLat'] as num?)?.toDouble(), // Parse optional pickup latitude
      pickupLng: (json['pickupLng'] as num?)?.toDouble(), // Parse optional pickup longitude
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(), // Parse optional dropoff latitude
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(), // Parse optional dropoff longitude
    );
  }

  // Convert the NotificationModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Notification ID
      'userId': userId, // User ID
      'message': message, // Message
      'createdAt': createdAt.toIso8601String(), // Creation time as ISO string
      if (pickupLat != null) 'pickupLat': pickupLat, // Optional pickup latitude
      if (pickupLng != null) 'pickupLng': pickupLng, // Optional pickup longitude
      if (dropoffLat != null) 'dropoffLat': dropoffLat, // Optional dropoff latitude
      if (dropoffLng != null) 'dropoffLng': dropoffLng, // Optional dropoff longitude
    };
  }
} 