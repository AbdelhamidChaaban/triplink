import 'package:flutter/material.dart'; // Import Flutter material design library
import '../../../models/trip_model.dart'; // Import trip model
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps Flutter
import '../../maps/map_picker_screen.dart'; // Import map picker screen
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import '../../../services/auth_service.dart'; // Import AuthService

class BookTripFormScreen extends StatefulWidget { // Define BookTripFormScreen widget
  final TripModel trip; // Trip to book
  final int selectedSeats; // Number of seats selected
  final Function(Map<String, String>) onBook; // Callback for booking

  const BookTripFormScreen({ // Constructor for BookTripFormScreen
    super.key, // Pass key to superclass
    required this.trip, // Require trip
    required this.selectedSeats, // Require selectedSeats
    required this.onBook, // Require onBook callback
  }); // End of constructor

  @override // Override createState method
  State<BookTripFormScreen> createState() => _BookTripFormScreenState(); // Create state for BookTripFormScreen
} // End of BookTripFormScreen class

class _BookTripFormScreenState extends State<BookTripFormScreen> { // Define state for BookTripFormScreen
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _nameController = TextEditingController(); // Controller for name input
  final _phoneController = TextEditingController(); // Controller for phone input
  final _pickupController = TextEditingController(); // Controller for pickup input
  final _dropoffController = TextEditingController(); // Controller for dropoff input
  bool _isLoading = false; // Loading state
  int _selectedSeats = 1; // Number of seats selected
  LatLng? _pickupLatLng; // Pickup location coordinates
  LatLng? _dropoffLatLng; // Dropoff location coordinates
  String? _pickupAddress; // Pickup address
  String? _dropoffAddress; // Dropoff address

  @override // Override initState method
  void initState() { // Initialize state
    super.initState(); // Call super initState
    _selectedSeats = widget.selectedSeats; // Set selected seats from widget
  } // End of initState

  @override // Override dispose method
  void dispose() { // Dispose controllers
    _nameController.dispose(); // Dispose name controller
    _phoneController.dispose(); // Dispose phone controller
    _pickupController.dispose(); // Dispose pickup controller
    _dropoffController.dispose(); // Dispose dropoff controller
    super.dispose(); // Call super dispose
  } // End of dispose

  Future<String?> _getAddressFromLatLng(LatLng location) async { // Get address from coordinates
    try { // Try block
      List<Placemark> placemarks = await placemarkFromCoordinates( // Get placemarks
        location.latitude, // Latitude
        location.longitude, // Longitude
      ); // End of placemarkFromCoordinates
      if (placemarks.isNotEmpty) { // If placemarks found
        Placemark place = placemarks[0]; // Use first placemark
        return '${place.street}, ${place.locality}, ${place.country}'; // Return formatted address
      } // End of if
    } catch (e) { // Catch block
      print('Error getting address: $e'); // Print error
    } // End of catch
    return null; // Return null if not found
  } // End of _getAddressFromLatLng

  Future<void> _selectPickupLocation() async { // Select pickup location
    final result = await Navigator.push( // Push map picker screen
      context, // Context
      MaterialPageRoute( // Create route
        builder: (context) => MapPickerScreen( // Build map picker
          singleLocationMode: true, // Single location mode
          markerHue: BitmapDescriptor.hueBlue, // Marker color
          initialLocation: _pickupLatLng, // Initial location
        ), // End of MapPickerScreen
      ), // End of MaterialPageRoute
    ); // End of Navigator.push
    if (result != null && result is LatLng) { // If result is LatLng
      setState(() { // Update state
        _pickupLatLng = result; // Set pickup coordinates
        _pickupAddress = null; // Clear pickup address
        _pickupController.text = 'Getting address...'; // Show loading text
      }); // End of setState

      // Get address for the selected location
      final address = await _getAddressFromLatLng(result); // Get address
      if (mounted) { // If widget is active
        setState(() { // Update state
          _pickupAddress = address; // Set pickup address
          _pickupController.text = address ?? 'Location selected'; // Set text
        }); // End of setState
      } // End of mounted
    } // End of if
  } // End of _selectPickupLocation

  Future<void> _selectDropoffLocation() async { // Select dropoff location
    final result = await Navigator.push( // Push map picker screen
      context, // Context
      MaterialPageRoute( // Create route
        builder: (context) => MapPickerScreen( // Build map picker
          singleLocationMode: true, // Single location mode
          markerHue: BitmapDescriptor.hueYellow, // Marker color
          initialLocation: _dropoffLatLng, // Initial location
        ), // End of MapPickerScreen
      ), // End of MaterialPageRoute
    ); // End of Navigator.push
    if (result != null && result is LatLng) { // If result is LatLng
      setState(() { // Update state
        _dropoffLatLng = result; // Set dropoff coordinates
        _dropoffAddress = null; // Clear dropoff address
        _dropoffController.text = 'Getting address...'; // Show loading text
      }); // End of setState

      // Get address for the selected location
      final address = await _getAddressFromLatLng(result); // Get address
      if (mounted) { // If widget is mounted
        setState(() { // Update state
          _dropoffAddress = address; // Set dropoff address
          _dropoffController.text = address ?? 'Location selected'; // Set text
        }); // End of setState
      } // End of mounted
    } // End of if
  } // End of _selectDropoffLocation

  void _submit() { // Submit booking form
    if (!_formKey.currentState!.validate()) return; // Validate form
    if (_pickupLatLng == null || _dropoffLatLng == null) { // Check if locations selected
      ScaffoldMessenger.of(context).showSnackBar( // Show error message
        const SnackBar(content: Text('Please select both pickup and dropoff locations')), // Error text
      ); // End of showSnackBar
      return; // Return early
    } // End of if
    print('BookTripFormScreen _submit called'); // Print debug

    // Show notification SnackBar to the driver
    if (widget.trip.driverId == AuthService().currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You May Have A New Notification'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onBook({ // Call onBook callback
      'pickup': _pickupAddress ?? _pickupController.text.trim(), // Pickup address
      'dropoff': _dropoffAddress ?? _dropoffController.text.trim(), // Dropoff address
      'seats': _selectedSeats.toString(), // Number of seats
      'pickupLat': _pickupLatLng!.latitude.toString(), // Pickup latitude
      'pickupLng': _pickupLatLng!.longitude.toString(), // Pickup longitude
      'dropoffLat': _dropoffLatLng!.latitude.toString(), // Dropoff latitude
      'dropoffLng': _dropoffLatLng!.longitude.toString(), // Dropoff longitude
    }); // End of onBook
  } // End of _submit

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return Scaffold( // Return Scaffold widget
      appBar: AppBar(title: const Text('Book Trip')), // App bar title
      body: SingleChildScrollView( // Make content scrollable
        padding: const EdgeInsets.all(24.0), // Add padding
        child: Form( // Create form
          key: _formKey, // Assign form key
          child: Column( // Create column layout
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [ // Start children list
              Card( // Create card
                child: Padding( // Add padding
                  padding: const EdgeInsets.all(16.0), // Padding value
                  child: Column( // Create column
                    crossAxisAlignment: CrossAxisAlignment.start, // Align start
                    children: [ // Start children list
                      Text( // Create text
                        'Select Number of Seats', // Text content
                        style: Theme.of(context).textTheme.titleMedium, // Text style
                      ), // End of Text
                      const SizedBox(height: 16), // Add spacing
                      Row( // Create row
                        mainAxisAlignment: MainAxisAlignment.center, // Center children
                        children: [ // Start children list
                          IconButton( // Create minus button
                            onPressed: _selectedSeats > 1
                                ? () => setState(() => _selectedSeats--)
                                : null, // Decrement seats
                            icon: const Icon(Icons.remove_circle_outline), // Minus icon
                          ), // End of IconButton
                          const SizedBox(width: 16), // Add spacing
                          Text( // Display selected seats
                            '$_selectedSeats', // Number of seats
                            style: Theme.of(context).textTheme.headlineMedium, // Text style
                          ), // End of Text
                          const SizedBox(width: 16), // Add spacing
                          IconButton( // Create plus button
                            onPressed: _selectedSeats < widget.trip.availableSeats
                                ? () => setState(() => _selectedSeats++)
                                : null, // Increment seats
                            icon: const Icon(Icons.add_circle_outline), // Plus icon
                          ), // End of IconButton
                        ], // End of children list
                      ), // End of Row
                      const SizedBox(height: 8), // Add spacing
                      Text( // Display available seats
                        'Available seats: ${widget.trip.availableSeats}', // Text content
                        style: Theme.of(context).textTheme.bodySmall, // Text style
                      ), // End of Text
                    ], // End of children list
                  ), // End of Column
                ), // End of Padding
              ), // End of Card
              const SizedBox(height: 24), // Add spacing
              TextFormField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pick Up Location',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: _selectPickupLocation,
                  ),
                ),
                readOnly: true,
                onTap: _selectPickupLocation,
                validator: (value) => value == null || value.isEmpty ? 'Please select your pick up location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dropoffController,
                decoration: InputDecoration(
                  labelText: 'Drop Off Location',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.yellow),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: _selectDropoffLocation,
                  ),
                ),
                readOnly: true,
                onTap: _selectDropoffLocation,
                validator: (value) => value == null || value.isEmpty ? 'Please select your drop off location' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 