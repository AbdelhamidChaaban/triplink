// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';

// Define HelpSupportScreen as a stateless widget for help and support
class HelpSupportScreen extends StatelessWidget {
  // Constructor for HelpSupportScreen
  const HelpSupportScreen({super.key});

  @override
  // Build the widget
  Widget build(BuildContext context) {
    // Return scaffold with app bar and body
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      // Body with list view
      body: ListView(
        // Add padding around content
        padding: const EdgeInsets.all(16),
        // List of children widgets
        children: [
          // Divider for spacing
          const Divider(height: 32),
          // Section header for contact support
          const _SectionHeader(title: 'Contact Support'),
          // List tile for email support
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Support'),
            subtitle: const Text('ahmadhaddad052@gmail.com\nabdelhamidchaaban052@gmail.com'),
            onTap: () {
              // TODO: Open email client
            },
          ),
          // List tile for call support
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Call Support'),
            subtitle: const Text('+961 81 417 697\n+961 81 106 131'),
            onTap: () {
              // TODO: Open phone dialer
            },
          ),
          // Divider for spacing
          const Divider(height: 32),
          // Section header for safety tips
          const _SectionHeader(title: 'Safety Tips'),
          // Safety tip: verify driver identity
          _SafetyTip(
            title: 'Verify Driver Identity',
            description: 'Always verify the driver\'s identity and vehicle details before starting your trip.',
          ),
          // Safety tip: share trip details
          _SafetyTip(
            title: 'Share Trip Details',
            description: 'Share your trip details with friends or family before starting your journey.',
          ),
          // Safety tip: check reviews
          _SafetyTip(
            title: 'Check Reviews',
            description: 'Read reviews from other passengers before booking a trip.',
          ),
          // Safety tip: report issues
          _SafetyTip(
            title: 'Report Issues',
            description: 'If you encounter any issues, report them immediately through the app or contact support.',
          ),
        ],
      ),
    );
  }
}

// Private widget for section headers
class _SectionHeader extends StatelessWidget {
  // Title for the section
  final String title;

  // Constructor for section header
  const _SectionHeader({required this.title});

  @override
  // Build the widget
  Widget build(BuildContext context) {
    // Return padded text for section header
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Private widget for safety tips
class _SafetyTip extends StatelessWidget {
  // Title for the safety tip
  final String title;
  // Description for the safety tip
  final String description;

  // Constructor for safety tip
  const _SafetyTip({
    required this.title,
    required this.description,
  });

  @override
  // Build the widget
  Widget build(BuildContext context) {
    // Return card with safety tip content
    return Card(
      // Margin below the card
      margin: const EdgeInsets.only(bottom: 8),
      // Padding inside the card
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Column for vertical layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the safety tip
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Add vertical space
            const SizedBox(height: 8),
            // Description of the safety tip
            Text(description),
          ],
        ),
      ),
    );
  }
} 