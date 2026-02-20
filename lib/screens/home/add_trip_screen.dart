// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import trip model for trip data structure
import '../../../models/trip_model.dart';
// Import trip service for managing trip data operations
import '../../../services/trip_service.dart';
// Import auth service for user authentication
import '../../../services/auth_service.dart';
// Import app theme utilities
import '../../../utils/theme.dart';
// Import map picker screen for selecting locations on a map
import '../maps/map_picker_screen.dart';
// Import Google Maps Flutter package for map functionality
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Define AddTripScreen as a stateful widget for adding a new trip
class AddTripScreen extends StatefulWidget {
  // Constructor for AddTripScreen
  const AddTripScreen({super.key});

  @override
  // Create state for AddTripScreen
  State<AddTripScreen> createState() => _AddTripScreenState();
}

// Define the state class for AddTripScreen
class _AddTripScreenState extends State<AddTripScreen> {
  // Key for the form
  final _formKey = GlobalKey<FormState>();
  // Controller for start location input
  final _startLocationController = TextEditingController();
  // Controller for end location input
  final _endLocationController = TextEditingController();
  // Controller for price input
  final _priceController = TextEditingController();
  // Controller for seats input
  final _seatsController = TextEditingController();
  // Controller for notes input
  final _notesController = TextEditingController();
  // Instance of trip service
  final _tripService = TripService();
  // Instance of auth service
  final _authService = AuthService();
  // Selected departure date
  DateTime? _departureDate;
  // Selected departure time
  TimeOfDay? _departureTime;
  // Loading state flag
  bool _isLoading = false;
  // Start location coordinates
  LatLng? _startLatLng;
  // End location coordinates
  LatLng? _endLatLng;
  // Start address string
  String? _startAddress;
  // End address string
  String? _endAddress;

  @override
  // Dispose controllers when widget is disposed
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Method to select a date using a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _departureDate) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  // Method to select a time using a time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _departureTime) {
      setState(() {
        _departureTime = picked;
      });
    }
  }

  // Method to pick a location using the map picker
  Future<void> _pickLocation(bool isStart) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          singleLocationMode: true,
          markerHue: BitmapDescriptor.hueGreen,
          initialLocation: isStart ? _startLatLng : _endLatLng,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        if (isStart) {
          _startLatLng = result;
        } else {
          _endLatLng = result;
        }
      });
    }
  }

  // Method to create a new trip
  Future<void> _createTrip() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) return;
    // Check if departure date and time are selected
    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select departure date and time')),
      );
      return;
    }
    // Check if start and end locations are selected
    if (_startLatLng == null || _endLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end locations')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get user model from auth service
      final userModel = await _authService.getUserData(user.uid);

      // Combine date and time into a DateTime object
      final departureDateTime = DateTime(
        // Year from the selected departure date
        _departureDate!.year,
        // Month from the selected departure date
        _departureDate!.month,
        // Day from the selected departure date
        _departureDate!.day,
        // Hour from the selected departure time
        _departureTime!.hour,
        // Minute from the selected departure time
        _departureTime!.minute,
      );

      // Create a new TripModel instance
      final trip = TripModel(
        // Unique trip ID based on current timestamp
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        // The user ID of the driver creating the trip
        driverId: user.uid,
        // List of passenger IDs (empty at creation)
        passengerIds: [],
        // Start location address (from address or text field)
        startLocation: _startAddress ?? _startLocationController.text.trim(),
        // End location address (from address or text field)
        endLocation: _endAddress ?? _endLocationController.text.trim(),
        // Latitude of the start location
        startLat: _startLatLng!.latitude,
        // Longitude of the start location
        startLng: _startLatLng!.longitude,
        // Latitude of the end location
        endLat: _endLatLng!.latitude,
        // Longitude of the end location
        endLng: _endLatLng!.longitude,
        // Price per seat (parsed from input)
        price: double.parse(_priceController.text),
        // Number of available seats (parsed from input)
        availableSeats: int.parse(_seatsController.text),
        // Price per seat (same as price field)
        pricePerSeat: double.parse(_priceController.text),
        // Status of the trip (scheduled by default)
        status: 'scheduled',
        // Optional notes for the trip
        notes: _notesController.text.trim(),
        // Creation timestamp
        createdAt: DateTime.now(),
        // Driver's name (from user model)
        driverName: userModel.name,
        // Driver's rating (default 5.0)
        driverRating: 5.0,
        // Driver's phone number (from user model)
        driverPhoneNumber: userModel.phoneNumber,
        // Departure date and time
        departureTime: departureDateTime,
      );

      // Save the trip using the trip service
      await _tripService.createTrip(trip);

      // If the widget is still mounted, show success and pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Show error if trip creation fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating trip: $e')),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  // Override the build method from StatefulWidget
  Widget build(BuildContext context) { // Build method that takes BuildContext as parameter
    return Scaffold( // Create a Scaffold widget as the root container
      appBar: AppBar( // Create an AppBar widget for the top navigation bar
        title: const Text('Add Trip'), // Set the title text to 'Add Trip'
      ),
      body: SingleChildScrollView( // Create a scrollable container for the form
        padding: const EdgeInsets.all(16.0), // Add padding of 16 pixels on all sides
        child: Form( // Create a Form widget for input validation
          key: _formKey, // Assign the form key for validation
          child: Column( // Create a Column widget for vertical layout
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [ // List of child widgets
              TextFormField( // Create a text input field for start location
                controller: _startLocationController, // Assign the controller for start location
                decoration: InputDecoration( // Customize the input field appearance
                  labelText: 'Start Location', // Set the label text
                  prefixIcon: const Icon(Icons.location_on), // Add location icon at start
                  suffixIcon: IconButton( // Add a button at the end
                    icon: const Icon(Icons.map), // Set map icon
                    onPressed: () => _pickLocation(true), // Call _pickLocation when pressed
                  ),
                ),
                onChanged: (value) { // Handle text changes
                  setState(() { // Update the state
                    _startLatLng = null; // Reset start coordinates
                    _startAddress = null; // Reset start address
                  });
                },
                validator: (value) { // Validate the input
                  if (value == null || value.isEmpty) { // Check if empty
                    return 'Please enter start location'; // Return error message
                  }
                  if (_startLatLng == null) { // Check if location is verified
                    return 'Please verify the location by clicking the map icon'; // Return error message
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 16), // Add 16 pixels of vertical space
              TextFormField( // Create a text input field for end location
                controller: _endLocationController, // Assign the controller for end location
                decoration: InputDecoration( // Customize the input field appearance
                  labelText: 'End Location', // Set the label text
                  prefixIcon: const Icon(Icons.location_on), // Add location icon at start
                  suffixIcon: IconButton( // Add a button at the end
                    icon: const Icon(Icons.map), // Set map icon
                    onPressed: () => _pickLocation(false), // Call _pickLocation when pressed
                  ),
                ),
                onChanged: (value) { // Handle text changes
                  setState(() { // Update the state
                    _endLatLng = null; // Reset end coordinates
                    _endAddress = null; // Reset end address
                  });
                },
                validator: (value) { // Validate the input
                  if (value == null || value.isEmpty) { // Check if empty
                    return 'Please enter end location'; // Return error message
                  }
                  if (_endLatLng == null) { // Check if location is verified
                    return 'Please verify the location by clicking the map icon'; // Return error message
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 16), // Add 16 pixels of vertical space
              Row( // Create a Row widget for horizontal layout
                children: [ // List of child widgets
                  Expanded( // Create an expanded widget to take available space
                    child: TextButton.icon( // Create a button with icon and text
                      onPressed: () => _selectDate(context), // Call _selectDate when pressed
                      icon: const Icon(Icons.calendar_today), // Set calendar icon
                      label: Text(_departureDate == null // Set the button text
                          ? 'Select Date' // Show if date not selected
                          : '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'), // Show selected date
                    ),
                  ),
                  const SizedBox(width: 16), // Add 16 pixels of horizontal space
                  Expanded( // Create an expanded widget to take available space
                    child: TextButton.icon( // Create a button with icon and text
                      onPressed: () => _selectTime(context), // Call _selectTime when pressed
                      icon: const Icon(Icons.access_time), // Set time icon
                      label: Text(_departureTime == null // Set the button text
                          ? 'Select Time' // Show if time not selected
                          : _departureTime!.format(context)), // Show selected time
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Add 16 pixels of vertical space
              TextFormField( // Create a text input field for price
                controller: _priceController, // Assign the controller for price
                decoration: const InputDecoration( // Customize the input field appearance
                  labelText: 'Price per Seat', // Set the label text
                  prefixIcon: Icon(Icons.attach_money), // Add money icon at start
                ),
                keyboardType: TextInputType.number, // Set keyboard type to number
                validator: (value) { // Validate the input
                  if (value == null || value.trim().isEmpty) { // Check if empty
                    return 'Please enter price'; // Return error message
                  }
                  if (double.tryParse(value) == null) { // Check if valid number
                    return 'Please enter a valid price'; // Return error message
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 16), // Add 16 pixels of vertical space
              TextFormField( // Create a text input field for seats
                controller: _seatsController, // Assign the controller for seats
                decoration: const InputDecoration( // Customize the input field appearance
                  labelText: 'Available Seats', // Set the label text
                  prefixIcon: Icon(Icons.airline_seat_recline_normal), // Add seat icon at start
                ),
                keyboardType: TextInputType.number, // Set keyboard type to number
                validator: (value) { // Validate the input
                  if (value == null || value.trim().isEmpty) { // Check if empty
                    return 'Please enter number of seats'; // Return error message
                  }
                  if (int.tryParse(value) == null) { // Check if valid number
                    return 'Please enter a valid number'; // Return error message
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 16), // Add 16 pixels of vertical space
              TextFormField( // Create a text input field for notes
                controller: _notesController, // Assign the controller for notes
                decoration: const InputDecoration( // Customize the input field appearance
                  labelText: 'Notes (Optional)', // Set the label text
                  prefixIcon: Icon(Icons.note), // Add note icon at start
                ),
                maxLines: 3, // Allow up to 3 lines of text
              ),
              const SizedBox(height: 24), // Add 24 pixels of vertical space
              ElevatedButton( // Create an elevated button
                onPressed: _isLoading ? null : _createTrip, // Disable if loading, call _createTrip when pressed
                style: ElevatedButton.styleFrom( // Customize button style
                  backgroundColor: AppTheme.primaryColor, // Set button color
                  padding: const EdgeInsets.symmetric(vertical: 16), // Add vertical padding
                ),
                child: _isLoading // Show loading indicator or button text
                    ? const SizedBox( // Create a sized box for loading indicator
                        height: 20, // Set height
                        width: 20, // Set width
                        child: CircularProgressIndicator( // Show loading indicator
                          strokeWidth: 2, // Set stroke width
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set color
                        ),
                      )
                    : const Text('Create Trip'), // Show button text
              ),
            ],
          ),
        ),
      ),
    );
  }
} 