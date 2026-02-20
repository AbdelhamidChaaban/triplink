import 'package:flutter/material.dart'; // Import Flutter material design library
import '../../services/auth_service.dart'; // Import authentication service
import '../../utils/theme.dart'; // Import app theme utilities
import '../home/home_screen.dart'; // Import home screen

class RegisterScreen extends StatefulWidget { // Define RegisterScreen widget
  const RegisterScreen({super.key}); // Constructor for RegisterScreen

  @override // Override createState method
  State<RegisterScreen> createState() => _RegisterScreenState(); // Create state for RegisterScreen
} // End of RegisterScreen class

class _RegisterScreenState extends State<RegisterScreen> { // Define RegisterScreen state
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _nameController = TextEditingController(); // Controller for name input
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input
  final _phoneController = TextEditingController(); // Controller for phone input
  final _authService = AuthService(); // Instance of authentication service
  bool _isLoading = false; // Flag to track loading state
  String? _errorMessage; // Variable to store error message

  @override // Override dispose method
  void dispose() { // Define dispose method
    _nameController.dispose(); // Dispose name controller
    _emailController.dispose(); // Dispose email controller
    _passwordController.dispose(); // Dispose password controller
    _phoneController.dispose(); // Dispose phone controller
    super.dispose(); // Call super dispose
  } // End of dispose method

  Future<void> _register() async { // Define register method
    if (!_formKey.currentState!.validate()) return; // Validate form

    setState(() { // Update state
      _isLoading = true; // Set loading state to true
      _errorMessage = null; // Clear error message
    }); // End of setState

    try { // Start try block
      await _authService.signUp( // Call sign up method
        email: _emailController.text.trim(), // Trim email input
        password: _passwordController.text.trim(), // Trim password input
        name: _nameController.text.trim(), // Trim name input
        phoneNumber: _phoneController.text.trim(), // Trim phone input
        isDriver: false, // Default to passenger
      ); // End of signUp call

      if (mounted) { // Check if widget is mounted
        Navigator.of(context).pushReplacement( // Navigate to new screen
          MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to home screen
        ); // End of pushReplacement
      } // End of mounted check
    } catch (e) { // Start catch block
      setState(() { // Update state
        _errorMessage = e.toString(); // Set error message
      }); // End of setState
    } finally { // Start finally block
      if (mounted) { // Check if widget is mounted
        setState(() { // Update state
          _isLoading = false; // Set loading state to false
        }); // End of setState
      } // End of mounted check
    } // End of finally block
  } // End of _register method

  @override // Override build method
  Widget build(BuildContext context) { // Define build method
    return Scaffold( // Return Scaffold widget
      appBar: AppBar( // Create app bar
        title: const Text('Create Account'), // App bar title
      ), // End of AppBar
      body: SafeArea( // Wrap body in SafeArea
        child: Center( // Center the content
          child: SingleChildScrollView( // Make content scrollable
            padding: const EdgeInsets.all(24.0), // Add padding
            child: Form( // Create form
              key: _formKey, // Assign form key
              child: Column( // Create column layout
                mainAxisAlignment: MainAxisAlignment.center, // Center children vertically
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [ // Start children list
                  Icon( // Create icon
                    Icons.car_rental, // Car rental icon
                    size: 80, // Icon size
                    color: AppTheme.primaryColor, // Icon color
                  ), // End of Icon
                  const SizedBox(height: 24), // Add spacing
                  Text( // Create text
                    'Join TripLink', // Join text
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith( // Style text
                          color: AppTheme.primaryColor, // Text color
                          fontWeight: FontWeight.bold, // Bold text
                        ), // End of copyWith
                    textAlign: TextAlign.center, // Center text
                  ), // End of Text
                  const SizedBox(height: 8), // Add spacing
                  Text( // Create text
                    'Create an account to get started', // Create account text
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith( // Style text
                          color: Colors.grey[600], // Text color
                        ), // End of copyWith
                    textAlign: TextAlign.center, // Center text
                  ), // End of Text
                  const SizedBox(height: 32), // Add spacing
                  TextFormField( // Create name input field
                    controller: _nameController, // Assign name controller
                    decoration: const InputDecoration( // Decorate input field
                      labelText: 'Full Name', // Name label
                      prefixIcon: Icon(Icons.person), // Person icon
                    ), // End of InputDecoration
                    validator: (value) { // Define validator
                      if (value == null || value.isEmpty) { // Check if empty
                        return 'Please enter your name'; // Return error message
                      } // End of empty check
                      return null; // No error
                    }, // End of validator
                  ), // End of TextFormField
                  const SizedBox(height: 16), // Add spacing
                  TextFormField( // Create email input field
                    controller: _emailController, // Assign email controller
                    keyboardType: TextInputType.emailAddress, // Email keyboard type
                    decoration: const InputDecoration( // Decorate input field
                      labelText: 'Email', // Email label
                      prefixIcon: Icon(Icons.email), // Email icon
                    ), // End of InputDecoration
                    validator: (value) { // Define validator
                      if (value == null || value.isEmpty) { // Check if empty
                        return 'Please enter your email'; // Return error message
                      } // End of empty check
                      if (!value.contains('@')) { // Check email format
                        return 'Please enter a valid email'; // Return error message
                      } // End of format check
                      return null; // No error
                    }, // End of validator
                  ), // End of TextFormField
                  const SizedBox(height: 16), // Add spacing
                  TextFormField( // Create password input field
                    controller: _passwordController, // Assign password controller
                    obscureText: true, // Hide password
                    decoration: const InputDecoration( // Decorate input field
                      labelText: 'Password', // Password label
                      prefixIcon: Icon(Icons.lock), // Lock icon
                    ), // End of InputDecoration
                    validator: (value) { // Define validator
                      if (value == null || value.isEmpty) { // Check if empty
                        return 'Please enter your password'; // Return error message
                      } // End of empty check
                      if (value.length < 6) { // Check password length
                        return 'Password must be at least 6 characters'; // Return error message
                      } // End of length check
                      return null; // No error
                    }, // End of validator
                  ), // End of TextFormField
                  const SizedBox(height: 16), // Add spacing
                  TextFormField( // Create phone input field
                    controller: _phoneController, // Assign phone controller
                    keyboardType: TextInputType.phone, // Phone keyboard type
                    decoration: const InputDecoration( // Decorate input field
                      labelText: 'Phone Number', // Phone label
                      prefixIcon: Icon(Icons.phone), // Phone icon
                    ), // End of InputDecoration
                    validator: (value) { // Define validator
                      if (value == null || value.isEmpty) { // Check if empty
                        return 'Please enter your phone number'; // Return error message
                      } // End of empty check
                      return null; // No error
                    }, // End of validator
                  ), // End of TextFormField
                  const SizedBox(height: 24), // Add spacing
                  if (_errorMessage != null) // Check if error exists
                    Padding( // Add padding
                      padding: const EdgeInsets.only(bottom: 16), // Add bottom padding
                      child: Text( // Create text
                        _errorMessage!, // Display error message
                        style: TextStyle(color: AppTheme.errorColor), // Error text color
                        textAlign: TextAlign.center, // Center text
                      ), // End of Text
                    ), // End of Padding
                  ElevatedButton( // Create create account button
                    onPressed: _isLoading ? null : _register, // Disable button if loading
                    child: _isLoading // Check loading state
                        ? const SizedBox( // Create loading indicator container
                            height: 20, // Set height
                            width: 20, // Set width
                            child: CircularProgressIndicator( // Create loading indicator
                              strokeWidth: 2, // Set stroke width
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set color
                            ), // End of CircularProgressIndicator
                          ) // End of SizedBox
                        : const Text('Create Account'), // Show create account text
                  ), // End of ElevatedButton
                ], // End of children list
              ), // End of Column
            ), // End of Form
          ), // End of SingleChildScrollView
        ), // End of Center
      ), // End of SafeArea
    ); // End of Scaffold
  } // End of build method
} // End of _RegisterScreenState class 