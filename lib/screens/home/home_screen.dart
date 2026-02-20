// Importing necessary Flutter material package for UI components
import 'package:flutter/material.dart';

// Importing a custom theme utility file for styling
import '../../utils/theme.dart';

// Importing different tab screens for the bottom navigation
import 'tabs/search_tab.dart';
import 'tabs/recent_trips_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/my_trips_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/profile_tab.dart';

// Defining a StatefulWidget for the main home screen
class HomeScreen extends StatefulWidget {
  // Constructor for HomeScreen widget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Creating state for HomeScreen
}

// Defining the state class for HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // Holds the index of the currently selected tab
  int _currentIndex = 0;

  // List of tab widgets that correspond to different sections in the app
  final List<Widget> _tabs = [
    const SearchTab(), // Search tab
    const RecentTripsTab(), // Recent trips tab
    const NotificationsTab(), // Notifications tab
    const MyTripsTab(), // My trips tab
    const ChatTab(), // Chat tab
    const ProfileTab(), // Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays the currently selected tab based on _currentIndex
      body: _tabs[_currentIndex],

      // Defines a bottom navigation bar for switching between tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlights the currently active tab
        onTap: (index) => setState(() => _currentIndex = index), // Updates the selected tab when tapped

        // Defines items for the navigation bar, each with an icon and label
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Search icon
            label: 'Search', // Label for search tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public), // Trips icon
            label: 'Trips', // Label for trips tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications), // Notifications icon
            label: 'Notifications', // Label for notifications tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car), // Car icon for My Trips
            label: 'My Trips', // Label for my trips tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // Chat icon
            label: 'Chat', // Label for chat tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Profile icon
            label: 'Profile', // Label for profile tab
          ),
        ],
        selectedItemColor: AppTheme.primaryColor, // Sets color for the selected tab
        unselectedItemColor: Colors.grey, // Sets color for unselected tabs
      ),
    );
  }
}