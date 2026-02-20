// Configuration for Google Maps API and related settings
class MapsConfig {
  // The API key used for Google Maps in web/browser builds
  static const String browserApiKey = 'AIzaSyAn4zfjPP4ZOZWARjawztac38NG7O4kdIg';
  
  // Map display settings
  // The default zoom level when the map is first shown
  static const double defaultZoom = 15.0;
  // The default latitude for the initial map center
  static const double defaultLatitude = 0.0;
  // The default longitude for the initial map center
  static const double defaultLongitude = 0.0;
  
  // Map style settings
  // The default size for map markers (not always used directly)
  static const double markerSize = 40.0;
  // The width of polylines (routes) drawn on the map
  static const double polylineWidth = 5.0;
  // The color of polylines (routes) drawn on the map (Material Blue)
  static const int polylineColor = 0xFF2196F3; // Material Blue
  
  // Map interaction settings
  // Whether to enable showing the user's current location on the map
  static const bool enableMyLocation = true;
  // Whether to show the "my location" button on the map
  static const bool enableMyLocationButton = true;
  // Whether to show zoom controls on the map
  static const bool enableZoomControls = true;
  // Whether to show the map toolbar (for directions, etc.)
  static const bool enableMapToolbar = true;
  
  // Map bounds
  // The minimum zoom level allowed on the map
  static const double minZoom = 5.0;
  // The maximum zoom level allowed on the map
  static const double maxZoom = 20.0;
  
  // Location accuracy settings
  // The desired accuracy for location requests, in meters
  static const double locationAccuracy = 10.0; // meters
  // The timeout for location requests, in seconds
  static const int locationTimeout = 10; // seconds
} 