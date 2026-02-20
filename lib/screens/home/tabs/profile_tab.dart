import 'package:flutter/material.dart'; // Import Flutter material design library
import '../settings_screen.dart'; // Import settings screen
import '../help_support_screen.dart'; // Import help & support screen
import '../../../services/auth_service.dart'; // Import authentication service
import '../../auth/login_screen.dart'; // Import login screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class ProfileTab extends StatelessWidget { // Define ProfileTab widget
  const ProfileTab({super.key}); // Constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    final authService = AuthService(); // Create auth service instance
    final user = authService.currentUser; // Get current user

    return Scaffold( // Return Scaffold widget
      body: user == null // If user is null
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : StreamBuilder<DocumentSnapshot>( // Stream user document
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(), // Listen to user document
              builder: (context, snapshot) { // Build user profile
                if (snapshot.hasError) { // If error
                  return const Center(child: Text('Something went wrong')); // Show error
                }

                if (snapshot.connectionState == ConnectionState.waiting) { // If loading
                  return const Center(child: CircularProgressIndicator()); // Show loading
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?; // Get user data
                final userName = userData?['name'] ?? 'User'; // Get user name

                return SingleChildScrollView( // Scrollable content
                  child: Column( // Main column
                    children: [ // Start children list
                      Container( // Profile header container
                        padding: const EdgeInsets.all(16), // Padding
                        decoration: BoxDecoration( // Header decoration
                          color: Theme.of(context).colorScheme.primary, // Header color
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24), // Rounded bottom left
                            bottomRight: Radius.circular(24), // Rounded bottom right
                          ), // End of BorderRadius
                        ), // End of BoxDecoration
                        child: Column( // Header column
                          children: [ // Start children list
                            const SizedBox(height: 16), // Spacing
                            Text( // User name
                              userName, // Name
                              style: const TextStyle(
                                fontSize: 24, // Font size
                                fontWeight: FontWeight.bold, // Bold
                                color: Colors.white, // Text color
                              ), // End of TextStyle
                            ), // End of Text
                            const SizedBox(height: 8), // Spacing
                            Text( // User email
                              user.email ?? '', // Email
                              style: const TextStyle(
                                color: Colors.white70, // Text color
                              ), // End of TextStyle
                            ), // End of Text
                          ], // End children list
                        ), // End of Column
                      ), // End of Container
                      const SizedBox(height: 24), // Spacing
                      _ProfileMenuItem( // Settings menu item
                        icon: Icons.settings, // Icon
                        title: 'Settings', // Title
                        onTap: () { // On tap
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(), // Navigate to settings
                            ), // End of MaterialPageRoute
                          ); // End of push
                        }, // End of onTap
                      ), // End of _ProfileMenuItem
                      _ProfileMenuItem( // Help & Support menu item
                        icon: Icons.help, // Icon
                        title: 'Help & Support', // Title
                        onTap: () { // On tap
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(), // Navigate to help & support
                            ), // End of MaterialPageRoute
                          ); // End of push
                        }, // End of onTap
                      ), // End of _ProfileMenuItem
                      _ProfileMenuItem( // Sign Out menu item
                        icon: Icons.logout, // Icon
                        title: 'Sign Out', // Title
                        onTap: () async { // On tap
                          try { // Try block
                            await authService.signOut(); // Sign out
                            if (context.mounted) { // If context is mounted
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(), // Navigate to login
                                ), // End of MaterialPageRoute
                              ); // End of pushReplacement
                            } // End of if
                          } catch (e) { // Catch block
                            if (context.mounted) { // If context is mounted
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error signing out: $e')), // Show error
                              ); // End of showSnackBar
                            } // End of if
                          } // End of catch
                        }, // End of onTap
                      ), // End of _ProfileMenuItem
                    ], // End children list
                  ), // End of Column
                ); // End of SingleChildScrollView
              }, // End of builder
            ), // End of StreamBuilder
    ); // End of Scaffold
  } // End of build method
} // End of ProfileTab class

class _ProfileMenuItem extends StatelessWidget { // Define _ProfileMenuItem widget
  final IconData icon; // Icon for menu item
  final String title; // Title for menu item
  final VoidCallback onTap; // Tap callback

  const _ProfileMenuItem({ // Constructor for _ProfileMenuItem
    required this.icon, // Require icon
    required this.title, // Require title
    required this.onTap, // Require onTap
  }); // End of constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return ListTile( // List tile for menu item
      leading: Icon(icon), // Leading icon
      title: Text(title), // Menu item title
      trailing: const Icon(Icons.chevron_right), // Chevron icon
      onTap: onTap, // On tap callback
    ); // End of ListTile
  } // End of build method
} // End of _ProfileMenuItem class 