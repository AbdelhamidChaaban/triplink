import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider widget for managing app theme (light/dark mode)
// Inherits from InheritedWidget to efficiently propagate theme changes down the widget tree
// Notifies all dependent widgets when theme changes
class ThemeProvider extends InheritedWidget {
  // Current theme mode (light/dark/system)
  final ThemeMode themeMode;
  // Callback function to handle theme changes
  final Function(ThemeMode) onThemeModeChanged;

  // Constructor for ThemeProvider
  // Parameters:
  //   - themeMode: Current theme mode
  //   - onThemeModeChanged: Function to call when theme changes
  //   - child: Child widget to wrap
  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
  });

  // Static method to get ThemeProvider instance from context
  // Parameters:
  //   - context: BuildContext to find the provider
  // Returns: ThemeProvider instance
  // Throws: Assertion error if no ThemeProvider found
  static ThemeProvider of(BuildContext context) {
    // Find the nearest ThemeProvider in the widget tree
    final ThemeProvider? result = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    // Ensure ThemeProvider exists
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  // Override method to determine if widget should notify dependents
  // Parameters:
  //   - oldWidget: Previous instance of ThemeProvider
  // Returns: true if theme mode has changed
  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

// Stateful widget to manage theme state
// Wraps the ThemeProvider and handles theme persistence
class ThemeProviderState extends StatefulWidget {
  // Child widget to wrap
  final Widget child;

  // Constructor for ThemeProviderState
  // Parameters:
  //   - child: Child widget to wrap
  const ThemeProviderState({super.key, required this.child});

  // Create state for ThemeProviderState
  @override
  State<ThemeProviderState> createState() => _ThemeProviderState();
}

// State class for ThemeProviderState
// Manages theme mode and persistence
class _ThemeProviderState extends State<ThemeProviderState> {
  // Current theme mode, defaults to system theme
  ThemeMode _themeMode = ThemeMode.system;
  // Shared preferences instance for persistent storage
  late SharedPreferences _prefs;

  // Initialize state when widget is created
  @override
  void initState() {
    super.initState();
    // Load saved theme mode from storage
    _loadThemeMode();
  }

  // Load saved theme mode from shared preferences
  // Converts stored string to ThemeMode enum
  Future<void> _loadThemeMode() async {
    // Get shared preferences instance
    _prefs = await SharedPreferences.getInstance();
    // Get saved theme mode string
    final String? themeModeString = _prefs.getString('theme_mode');
    // If theme mode was saved, update state
    if (themeModeString != null) {
      setState(() {
        // Convert string to ThemeMode enum
        _themeMode = ThemeMode.values.firstWhere(
          // Find matching ThemeMode value
          (mode) => mode.toString() == themeModeString,
          // Default to system theme if not found
          orElse: () => ThemeMode.system,
        );
      });
    }
  }

  // Update theme mode and save to persistent storage
  // Parameters:
  //   - mode: New theme mode to set
  void _setThemeMode(ThemeMode mode) async {
    // Update state with new theme mode
    setState(() {
      _themeMode = mode;
    });
    // Save theme mode to shared preferences
    await _prefs.setString('theme_mode', mode.toString());
  }

  // Build method to create widget tree
  @override
  Widget build(BuildContext context) {
    // Return ThemeProvider with current theme mode and change handler
    return ThemeProvider(
      // Pass current theme mode
      themeMode: _themeMode,
      // Pass theme change handler
      onThemeModeChanged: _setThemeMode,
      // Pass child widget
      child: widget.child,
    );
  }
} 