import 'package:flutter/material.dart'; // Import Flutter material design library
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../../../services/trip_service.dart'; // Import trip service
import '../../../models/trip_request_model.dart'; // Import trip request model
import '../../../services/auth_service.dart'; // Import authentication service
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps Flutter
import '../../maps/map_picker_screen.dart'; // Import map picker screen
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class CreateTripRequestScreen extends StatefulWidget { // Define CreateTripRequestScreen widget
  const CreateTripRequestScreen({super.key}); // Constructor

  @override // Override createState method
  State<CreateTripRequestScreen> createState() => _CreateTripRequestScreenState(); // Create state
} // End of CreateTripRequestScreen class

class _CreateTripRequestScreenState extends State<CreateTripRequestScreen> { // Define state for CreateTripRequestScreen
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _startController = TextEditingController(); // Controller for start location
  final _endController = TextEditingController(); // Controller for end location
  final _seatsController = TextEditingController(); // Controller for seats wanted
  DateTime? _dateWanted; // Date wanted
  bool _isLoading = false; // Loading state
  LatLng? _startLatLng; // Start location coordinates
  LatLng? _endLatLng; // End location coordinates
  String? _startAddress; // Start address
  String? _endAddress; // End address

  @override // Override dispose method
  void dispose() { // Dispose controllers
    _startController.dispose(); // Dispose start controller
    _endController.dispose(); // Dispose end controller
    _seatsController.dispose(); // Dispose seats controller
    super.dispose(); // Call super dispose
  } // End of dispose

  Future<void> _pickDate() async { // Pick a date
    final now = DateTime.now(); // Get current date
    final picked = await showDatePicker( // Show date picker
      context: context, // Context
      initialDate: now, // Initial date
      firstDate: now, // First selectable date
      lastDate: now.add(const Duration(days: 365)), // Last selectable date
    ); // End of showDatePicker
    if (picked != null) { // If a date was picked
      setState(() => _dateWanted = picked); // Set date wanted
    } // End of if
  } // End of _pickDate

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

  Future<void> _pickLocation(bool isStart) async { // Pick a location on the map
    final result = await Navigator.push( // Push map picker screen
      context, // Context
      MaterialPageRoute( // Create route
        builder: (context) => MapPickerScreen( // Build map picker
          singleLocationMode: true, // Single location mode
          markerHue: BitmapDescriptor.hueGreen, // Marker color
          initialLocation: isStart ? _startLatLng : _endLatLng, // Initial location
        ), // End of MapPickerScreen
      ), // End of MaterialPageRoute
    ); // End of Navigator.push

    if (result != null && result is LatLng) { // If result is LatLng
      setState(() {
        if (isStart) {
          _startLatLng = result; // Set start coordinates
          _startAddress = null; // Clear previous address
          _startController.text = 'Getting address...'; // Show loading text
        } else {
          _endLatLng = result; // Set end coordinates
          _endAddress = null; // Clear previous address
          _endController.text = 'Getting address...'; // Show loading text
        }
      }); // End of setState

      // Get address for the selected location
      final address = await _getAddressFromLatLng(result); // Get address
      if (mounted) {
        setState(() {
          if (isStart) {
            _startAddress = address; // Set start address
            _startController.text = address ?? 'Location selected'; // Set text
          } else {
            _endAddress = address; // Set end address
            _endController.text = address ?? 'Location selected'; // Set text
          }
        }); // End of setState
      } // End of mounted
    } // End of if
  } // End of _pickLocation

  Future<void> _submit() async { // Submit trip request
    if (!_formKey.currentState!.validate() || _dateWanted == null) return; // Validate form and date
    if (_startLatLng == null || _endLatLng == null) { // Check if locations selected
      ScaffoldMessenger.of(context).showSnackBar( // Show error message
        const SnackBar(content: Text('Please select both start and end locations on the map')), // Error text
      ); // End of showSnackBar
      return; // Return early
    } // End of if

    setState(() => _isLoading = true); // Set loading state
    try { // Try block
      final user = AuthService().currentUser; // Get current user
      if (user == null) throw Exception('User not logged in'); // Throw if not logged in
      final request = TripRequestModel( // Create trip request model
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID
        userId: user.uid, // User ID
        startLocation: _startAddress ?? _startController.text.trim(), // Start location
        endLocation: _endAddress ?? _endController.text.trim(), // End location
        startLat: _startLatLng!.latitude, // Start latitude
        startLng: _startLatLng!.longitude, // Start longitude
        endLat: _endLatLng!.latitude, // End latitude
        endLng: _endLatLng!.longitude, // End longitude
        seatsWanted: int.parse(_seatsController.text.trim()), // Seats wanted
        dateWanted: _dateWanted!, // Date wanted
        createdAt: DateTime.now(), // Creation time
      ); // End of TripRequestModel
      await TripService().createTripRequest(request); // Create trip request in Firestore
      if (mounted) {
        Navigator.pop(context, true); // Pop screen
      }
    } catch (e) { // Catch block
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( // Show error message
          SnackBar(content: Text('Error: $e')), // Error text
        ); // End of showSnackBar
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Reset loading state
    }
  } // End of _submit

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return Scaffold( // Return Scaffold widget
      appBar: AppBar(title: const Text('Create Trip Request')), // App bar title
      body: Padding( // Add padding
        padding: const EdgeInsets.all(24.0), // Padding value
        child: Form( // Create form
          key: _formKey, // Assign form key
          child: Column( // Create column layout
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [ // Start children list
              TextFormField( // Start location field
                controller: _startController, // Assign controller
                decoration: InputDecoration( // Input decoration
                  labelText: 'Start Location', // Label
                  suffixIcon: IconButton( // Map icon
                    icon: const Icon(Icons.map), // Icon
                    onPressed: () => _pickLocation(true), // Pick start location
                  ), // End of IconButton
                ), // End of InputDecoration
                readOnly: true, // Read only
                onTap: () => _pickLocation(true), // Pick start location
                validator: (v) => v == null || v.isEmpty ? 'Enter start location' : null, // Validation
              ), // End of TextFormField
              const SizedBox(height: 16), // Spacing
              TextFormField( // End location field
                controller: _endController, // Assign controller
                decoration: InputDecoration( // Input decoration
                  labelText: 'End Location', // Label
                  suffixIcon: IconButton( // Map icon
                    icon: const Icon(Icons.map), // Icon
                    onPressed: () => _pickLocation(false), // Pick end location
                  ), // End of IconButton
                ), // End of InputDecoration
                readOnly: true, // Read only
                onTap: () => _pickLocation(false), // Pick end location
                validator: (v) => v == null || v.isEmpty ? 'Enter end location' : null, // Validation
              ), // End of TextFormField
              const SizedBox(height: 16), // Spacing
              TextFormField( // Seats wanted field
                controller: _seatsController, // Assign controller
                decoration: const InputDecoration(labelText: 'Seats Wanted'), // Label
                keyboardType: TextInputType.number, // Number input
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter seats wanted'; // Validation
                  final n = int.tryParse(v); // Parse number
                  if (n == null || n < 1) return 'Enter a valid number'; // Validation
                  return null; // No error
                }, // End of validator
              ), // End of TextFormField
              const SizedBox(height: 16), // Spacing
              Row( // Row for date picker
                children: [ // Start children list
                  Expanded(
                    child: Text(_dateWanted == null
                        ? 'No date selected'
                        : 'Date: ${DateFormat('yyyy-MM-dd').format(_dateWanted!)}'),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 