// Importing Flutter's material package, which provides essential UI widgets
import 'package:flutter/material.dart';

// Importing a custom theme provider, used to manage the app's theme settings
import '../../utils/theme_provider.dart';

// Importing the screen for changing passwords
import 'change_password_screen.dart';

// Defining the SettingsScreen widget as a StatefulWidget (since the UI updates dynamically)
class SettingsScreen extends StatefulWidget {
  // Constructor for SettingsScreen, calling the superclass constructor
  const SettingsScreen({super.key});

  // Creating the state for SettingsScreen
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// Defining the state class for SettingsScreen, responsible for handling UI updates
class _SettingsScreenState extends State<SettingsScreen> {
  // Declaring a variable to track the selected theme (default: 'System')
  String _selectedTheme = 'System';

  // Called when dependencies change, such as when the theme updates
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Getting the current theme mode from ThemeProvider
    final themeProvider = ThemeProvider.of(context);
    
    // Checking the current theme and updating _selectedTheme accordingly
    switch (themeProvider.themeMode) {
      case ThemeMode.system: // If the theme is set to system default
        _selectedTheme = 'System';
        break;
      case ThemeMode.light: // If the theme is set to light mode
        _selectedTheme = 'Light';
        break;
      case ThemeMode.dark: // If the theme is set to dark mode
        _selectedTheme = 'Dark';
        break;
    }
  }

  // Building the UI of the SettingsScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Creating an app bar with the title 'Settings'
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      // Using ListView to allow scrolling through different settings sections
      body: ListView(
        children: [
          // Adding a section header for account-related settings
          const _SectionHeader(title: 'Account'),

          // Creating a list tile for the 'Change Password' option
          ListTile(
            leading: const Icon(Icons.lock), // Displaying a lock icon
            title: const Text('Change Password'), // Text for the option
            trailing: const Icon(Icons.chevron_right), // Right arrow icon indicating navigation
            onTap: () {
              // Navigating to the ChangePasswordScreen when the list tile is tapped
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),

          // Adding a visual divider to separate sections
          const Divider(),

          // Adding a section header for preference-related settings
          const _SectionHeader(title: 'Preferences'),

          // Creating a list tile for selecting the app theme
          ListTile(
            leading: const Icon(Icons.palette), // Displaying a palette icon
            title: const Text('Theme'), // Text for the theme selection option
            trailing: DropdownButton<String>( // Dropdown button for selecting a theme
              value: _selectedTheme, // Sets the selected theme
              underline: const SizedBox(), // Removes the default underline

              // Creating dropdown menu items for theme selection
              items: const [
                DropdownMenuItem(
                  value: 'System', // Represents system default theme
                  child: Text('System'), // Display text for the option
                ),
                DropdownMenuItem(
                  value: 'Light', // Represents light mode theme
                  child: Text('Light'), // Display text for the option
                ),
                DropdownMenuItem(
                  value: 'Dark', // Represents dark mode theme
                  child: Text('Dark'), // Display text for the option
                ),
              ],

              // Handling the theme selection when the user changes the dropdown value
              onChanged: (value) {
                if (value != null) {
                  // Updating the selected theme and triggering UI update
                  setState(() => _selectedTheme = value);

                  // Retrieving the ThemeProvider to update the app theme mode
                  final themeProvider = ThemeProvider.of(context);

                  // Applying the chosen theme
                  switch (value) {
                    case 'System': // If 'System' is selected
                      themeProvider.onThemeModeChanged(ThemeMode.system);
                      break;
                    case 'Light': // If 'Light' is selected
                      themeProvider.onThemeModeChanged(ThemeMode.light);
                      break;
                    case 'Dark': // If 'Dark' is selected
                      themeProvider.onThemeModeChanged(ThemeMode.dark);
                      break;
                  }
                }
              },
            ),
          ),

          // Adding a visual divider to separate sections
          const Divider(),

          // Adding a section header for app information
          const _SectionHeader(title: 'App Info'),

          // Creating a list tile for displaying the app version
          ListTile(
            leading: const Icon(Icons.info), // Displaying an info icon
            title: const Text('Version'), // Text for the app version option
            trailing: const Text('1.0.0'), // Showing the current app version
          ),
        ],
      ),
    );
  }
}

// Defining a reusable section header widget
class _SectionHeader extends StatelessWidget {
  final String title; // Declaring the title for the section header

  // Constructor to initialize the section header with a title
  const _SectionHeader({required this.title});

  // Building the UI of the section header
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adding padding to the section header text
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      
      // Displaying the section header text with styling
      child: Text(
        title, // Setting the text to the provided section title
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary, // Using primary color from the app theme
          fontWeight: FontWeight.bold, // Applying bold font weight
          fontSize: 14, // Setting font size
        ),
      ),
    );
  }
}