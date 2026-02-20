import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Static class containing theme data and color schemes for the app
// Defines consistent styling across the application
class AppTheme {
  // Primary color used for main UI elements (purple)
  static const Color primaryColor = Color(0xFF6750A4);
  // Secondary color for accent elements (purple)
  static const Color secondaryColor = Color(0xFF9C27B0);
  // Accent color for subtle highlights (light purple)
  static const Color accentColor = Color(0xFFE1BEE7);
  // Background color for light theme (light gray)
  static const Color backgroundColor = Color(0xFFF5F5F5);
  // Error color for error states and messages (red)
  static const Color errorColor = Color(0xFFD32F2F);
  // Success color for success states and messages (green)
  static const Color successColor = Color(0xFF388E3C);

  // Getter for light theme configuration
  // Returns a ThemeData object with light theme settings
  static ThemeData get lightTheme {
    return ThemeData(
      // Enable Material 3 design system
      useMaterial3: true,
      // Define color scheme for light theme
      colorScheme: ColorScheme.light(
        primary: primaryColor,      // Main brand color
        secondary: secondaryColor,  // Secondary brand color
        error: errorColor,         // Error state color
        surface: backgroundColor,  // Surface color for cards and sheets
      ),
      // Set text theme using Google Fonts (Poppins)
      textTheme: GoogleFonts.poppinsTextTheme(),
      // Configure app bar appearance
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,  // App bar background color
        foregroundColor: Colors.white,  // App bar text color
        elevation: 0,                  // Remove shadow
      ),
      // Configure elevated button appearance
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,    // Button background color
          foregroundColor: Colors.white,    // Button text color
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),  // Button padding
          shape: RoundedRectangleBorder(    // Button shape
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Configure input field appearance
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                      // Fill input background
        fillColor: Colors.white,           // Input background color
        border: OutlineInputBorder(        // Default border
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder( // Border when input is enabled
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder( // Border when input is focused
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(   // Border when input has error
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),  // Input padding
      ),
      // Configure card appearance
      cardTheme: CardThemeData(
        elevation: 2,                      // Card shadow
        shape: RoundedRectangleBorder(     // Card shape
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Getter for dark theme configuration
  // Returns a ThemeData object with dark theme settings
  static ThemeData get darkTheme {
    return ThemeData(
      // Enable Material 3 design system
      useMaterial3: true,
      // Define color scheme for dark theme
      colorScheme: ColorScheme.dark(
        primary: primaryColor,      // Main brand color
        secondary: secondaryColor,  // Secondary brand color
        error: errorColor,         // Error state color
        surface: const Color(0xFF1C1B1F),  // Dark surface color
        background: const Color(0xFF121212),  // Dark background color
      ),
      // Set text theme using Google Fonts (Poppins) with dark theme base
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      // Configure app bar appearance for dark theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1B1F),  // Dark app bar background
        foregroundColor: Colors.white,       // App bar text color
        elevation: 0,                       // Remove shadow
      ),
      // Configure elevated button appearance for dark theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,    // Button background color
          foregroundColor: Colors.white,    // Button text color
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),  // Button padding
          shape: RoundedRectangleBorder(    // Button shape
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Configure input field appearance for dark theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                      // Fill input background
        fillColor: const Color(0xFF2C2C2C),  // Dark input background
        border: OutlineInputBorder(        // Default border
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder( // Border when input is enabled
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder( // Border when input is focused
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(   // Border when input has error
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),  // Input padding
      ),
      // Configure card appearance for dark theme
      cardTheme: CardThemeData(
        elevation: 2,                      // Card shadow
        color: const Color(0xFF1C1B1F),    // Dark card background
        shape: RoundedRectangleBorder(     // Card shape
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Set scaffold background color for dark theme
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
} 