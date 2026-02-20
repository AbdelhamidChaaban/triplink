// Main entry point of the app
// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import Firebase Core for Firebase initialization
import 'package:firebase_core/firebase_core.dart';
// Import Google Fonts for custom typography
import 'package:google_fonts/google_fonts.dart';
// Import custom theme configuration
import 'utils/theme.dart';
// Import theme provider for theme management
import 'utils/theme_provider.dart';
// Import authentication service
import 'services/auth_service.dart';
// Import main screens
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/add_trip_screen.dart';
// Import Firebase configuration options
import 'firebase_options.dart';

// Main function - entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app with MyApp as the root widget
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  // Constructor with key parameter
  const MyApp({super.key});

  // Build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    // Wrap the app with ThemeProviderState for theme management
    return ThemeProviderState(
      child: Builder(
        builder: (context) {
          // Get the current theme provider instance
          final themeProvider = ThemeProvider.of(context);
          // Return MaterialApp as the root widget
          return MaterialApp(
            title: 'TripLink',  // App name
            debugShowCheckedModeBanner: false,  // Hide debug banner
            theme: AppTheme.lightTheme,  // Light theme configuration
            darkTheme: AppTheme.darkTheme,  // Dark theme configuration
            themeMode: themeProvider.themeMode,  // Current theme mode
            home: const SplashScreen(),  // Initial screen
            // Define named routes for navigation
            routes: {
              '/login': (context) => const LoginScreen(),  // Login screen route
              '/addTrip': (context) => const AddTripScreen(),  // Add trip screen route
            },
          );
        },
      ),
    );
  }
}

// Splash screen widget - shown when app starts
class SplashScreen extends StatefulWidget {
  // Constructor with key parameter
  const SplashScreen({super.key});

  // Create state for SplashScreen
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State class for SplashScreen
class _SplashScreenState extends State<SplashScreen> {
  // Initialize state
  @override
  void initState() {
    super.initState();
    // Check authentication state when screen loads
    _checkAuthState();
  }

  // Check user authentication state
  Future<void> _checkAuthState() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    // Check if widget is still mounted
    if (!mounted) return;

    // Get authentication service instance
    final authService = AuthService();
    // Check if user is logged in
    if (authService.currentUser != null) {
      // Navigate to home screen if user is logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Navigate to login screen if user is not logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Build method to create splash screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color to primary theme color
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Center content vertically
          children: [
            // App icon
            const Icon(
              Icons.car_rental,  // Car rental icon
              size: 100,  // Icon size
              color: Colors.white,  // Icon color
            ),
            const SizedBox(height: 20),  // Vertical spacing
            // App name text
            Text(
              'TripLink',
              style: GoogleFonts.poppins(  // Use Poppins font
                fontSize: 32,  // Text size
                fontWeight: FontWeight.bold,  // Bold text
                color: Colors.white,  // Text color
              ),
            ),
            const SizedBox(height: 10),  // Vertical spacing
            // App tagline text
            Text(
              'Share Your Journey',
              style: GoogleFonts.poppins(  // Use Poppins font
                fontSize: 16,  // Text size
                color: Colors.white70,  // Slightly transparent white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
