import 'package:flutter/material.dart'; // Import Flutter material design library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'chat_room_screen.dart'; // Import chat room screen
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'notification_map_screen.dart'; // Import notification map screen

class NotificationsTab extends StatelessWidget { // Define NotificationsTab widget
  const NotificationsTab({super.key}); // Constructor

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return Scaffold( // Return Scaffold widget
      appBar: AppBar(title: const Text('Notifications')), // App bar title
      body: StreamBuilder<User?>( // Stream user auth state
        stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state
        builder: (context, userSnapshot) { // Build for user
          final user = userSnapshot.data; // Get user
          if (user == null) { // If not logged in
            return const Center(child: Text('You are not logged in.')); // Show not logged in
          } // End of if
          return StreamBuilder<QuerySnapshot>( // Stream notifications
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: user.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(), // Listen to notifications
            builder: (context, snapshot) { // Build notification list
              if (snapshot.connectionState == ConnectionState.waiting) { // If loading
                return const Center(child: CircularProgressIndicator()); // Show loading
              } // End of if
              if (snapshot.hasError) { // If error
                return Center(child: Text('Error: ${snapshot.error}')); // Show error
              } // End of if
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // If no notifications
                return const Center(child: Text('There is no unseen notification')); // Show no notifications
              } // End of if
              final notifications = snapshot.data!.docs; // Get notifications
              return ListView.builder( // Build notification list
                itemCount: notifications.length, // Number of notifications
                itemBuilder: (context, index) { // Build each notification
                  final notif = notifications[index].data() as Map<String, dynamic>; // Notification data
                  print('Notification: ' + notif.toString()); // Print notification
                  final hasResponded = notif['hasResponded'] ?? false; // Check if responded
                  return Card( // Notification card
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Card margin
                    child: ListTile( // List tile for notification
                      title: Text( // Notification message
                        notif['message']?.replaceAll('Phone:', '').replaceAll('\n\n', '\n') ?? '', // Message text
                      ), // End of Text
                      subtitle: Column( // Subtitle column
                        crossAxisAlignment: CrossAxisAlignment.start, // Align start
                        children: [ // Start children list
                          Text( // Notification time
                            notif['createdAt'] != null
                                ? DateTime.parse(notif['createdAt']).toLocal().toString()
                                : '', // Time text
                          ), // End of Text
                          if (notif['pickupLat'] != null && notif['pickupLng'] != null && notif['dropoffLat'] != null && notif['dropoffLng'] != null)
                            Padding( // Add padding
                              padding: const EdgeInsets.only(top: 8.0), // Padding value
                              child: ElevatedButton.icon( // More Details button
                                icon: const Icon(Icons.map), // Map icon
                                label: const Text('More Details'), // Button text
                                onPressed: () { // On press
                                  Navigator.of(context).push( // Navigate to map screen
                                    MaterialPageRoute( // Create route
                                      builder: (_) => NotificationMapScreen( // Build map screen
                                        pickupLat: notif['pickupLat'], // Pickup latitude
                                        pickupLng: notif['pickupLng'], // Pickup longitude
                                        dropoffLat: notif['dropoffLat'], // Dropoff latitude
                                        dropoffLng: notif['dropoffLng'], // Dropoff longitude
                                      ), // End of NotificationMapScreen
                                    ), // End of MaterialPageRoute
                                  ); // End of push
                                }, // End of onPressed
                              ), // End of ElevatedButton.icon
                            ), // End of Padding
                        ], // End children list
                      ), // End of Column
                      trailing: notif['passengerId'] != null && !hasResponded
                          ? ElevatedButton( // Send Hi button
                              onPressed: () async { // On press
                                final chatRoomId = _getChatRoomId(user.uid, notif['passengerId']); // Get chat room ID
                                // Create chat room
                                await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
                                  'participants': [user.uid, notif['passengerId']], // Participants
                                  'createdAt': DateTime.now().toIso8601String(), // Created at
                                  'lastMessage': 'Hi', // Last message
                                  'lastMessageTime': DateTime.now().toIso8601String(), // Last message time
                                }); // End of set
                                // Add initial "Hi" message
                                await FirebaseFirestore.instance.collection('chats/$chatRoomId/messages').add({
                                  'text': 'Hi', // Message text
                                  'createdAt': DateTime.now().toIso8601String(), // Created at
                                  'senderId': user.uid, // Sender ID
                                }); // End of add
                                // Mark notification as responded
                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(notifications[index].id)
                                    .update({'hasResponded': true}); // Update notification
                                if (context.mounted) { // If context is mounted
                                  Navigator.of(context).push( // Navigate to chat room
                                    MaterialPageRoute( // Create route
                                      builder: (context) => ChatRoomScreen( // Build chat room
                                        chatRoomId: chatRoomId, // Chat room ID
                                        otherUserName: 'Passenger', // Other user name
                                      ), // End of ChatRoomScreen
                                    ), // End of MaterialPageRoute
                                  ); // End of push
                                } // End of if
                              }, // End of onPressed
                              child: const Text('Send Hi'), // Button text
                            ) // End of ElevatedButton
                          : null, // No trailing button
                    ), // End of ListTile
                  ); // End of Card
                }, // End of itemBuilder
              ); // End of ListView.builder
            }, // End of builder
          ); // End of StreamBuilder
        }, // End of builder
      ), // End of StreamBuilder
    ); // End of Scaffold
  } // End of build method

  String _getChatRoomId(String uid1, String uid2) { // Get chat room ID
    final sorted = [uid1, uid2]..sort(); // Sort user IDs
    return sorted.join('_'); // Join IDs with underscore
  } // End of _getChatRoomId
} // End of NotificationsTab class 