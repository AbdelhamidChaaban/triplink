// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import authentication service for user management
import '../../services/auth_service.dart';
// Import app theme utilities
import '../../utils/theme.dart';

// Define ChangePasswordScreen as a stateful widget for changing user password
class ChangePasswordScreen extends StatefulWidget {
  // Constructor for ChangePasswordScreen
  const ChangePasswordScreen({super.key});

  @override
  // Create state for ChangePasswordScreen
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

// Define the state class for ChangePasswordScreen
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Key for the form
  final _formKey = GlobalKey<FormState>();
  // Controller for current password input
  final _currentPasswordController = TextEditingController();
  // Controller for new password input
  final _newPasswordController = TextEditingController();
  // Controller for confirm password input
  final _confirmPasswordController = TextEditingController();
  // Instance of authentication service
  final _authService = AuthService();
  // Loading state flag
  bool _isLoading = false;
  // Error message string
  String? _errorMessage;
  // Success message string
  String? _successMessage;

  @override
  // Dispose controllers when widget is disposed
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to change the user's password
  Future<void> _changePassword() async { // Define async method for password change
    // Validate the form
    if (!_formKey.currentState!.validate()) return; // Return if form validation fails
    // Set loading and clear messages
    setState(() { // Update the widget's state
      _isLoading = true; // Set loading state to true
      _errorMessage = null; // Clear any existing error message
      _successMessage = null; // Clear any existing success message
    });
    try { // Begin try-catch block for error handling
      // Re-authenticate user
      await _authService.signIn( // Call signIn method from auth service
        email: _authService.currentUser?.email ?? '', // Get current user's email or empty string
        password: _currentPasswordController.text.trim(), // Get trimmed current password from controller
      );
      // Update password
      await _authService.currentUser?.updatePassword( // Call updatePassword method on current user
        _newPasswordController.text.trim() // Get trimmed new password from controller
      );
      // Set success message
      setState(() { // Update the widget's state
        _successMessage = 'Password changed successfully!'; // Set success message
      });
    } catch (e) { // Catch any errors that occur
      // Set error message
      setState(() { // Update the widget's state
        _errorMessage = 'Failed to change password: ${e.toString()}'; // Set error message with exception details
      });
    } finally { // Execute regardless of success or failure
      // Reset loading state
      setState(() { // Update the widget's state
        _isLoading = false; // Set loading state back to false
      });
    }
  }

  @override
  // Build the widget
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      // Safe area for content
      body: SafeArea(
        // Center content vertically
        child: Center(
          // Scrollable content
          child: SingleChildScrollView(
            // Add padding around content
            padding: const EdgeInsets.all(24.0),
            // Form for password change
            child: Form(
              key: _formKey,
              // Column for vertical layout
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current password input
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  // Add vertical space
                  const SizedBox(height: 16),
                  // New password input
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  // Add vertical space
                  const SizedBox(height: 16),
                  // Confirm new password input
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  // Add vertical space
                  const SizedBox(height: 24),
                  // Show error message if present
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Show success message if present
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: AppTheme.successColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Change password button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Change Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 