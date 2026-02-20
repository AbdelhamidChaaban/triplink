import 'package:flutter/material.dart'; // Import Flutter material design library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../../../services/auth_service.dart'; // Import authentication service
import 'chat_room_screen.dart'; // Import chat room screen

class ChatTab extends StatelessWidget { // Define ChatTab widget
  const ChatTab({super.key}); // Constructor for ChatTab

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    final currentUser = AuthService().currentUser; // Get current user
    if (currentUser == null) { // If user not logged in
      return const Scaffold( // Show not logged in message
        body: Center(child: Text('You are not logged in.')), // Centered text
      ); // End of Scaffold
    } // End of if

    return Scaffold( // Return Scaffold widget
      appBar: AppBar( // App bar
        title: const Text('Chat'), // App bar title
        elevation: 0, // No elevation
      ), // End of AppBar
      body: StreamBuilder<QuerySnapshot>( // Stream chat rooms
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(), // Listen to chat rooms , meaning - TripLink receives real-time updates
        builder: (context, chatSnapshot) { // Build chat list
          if (chatSnapshot.connectionState == ConnectionState.waiting) { // If loading
            return const Center(child: CircularProgressIndicator()); // Show loading
          } // End of if

          if (chatSnapshot.hasError) { // If error
            return Center( // Show error
              child: Text('Error: ${chatSnapshot.error}'), // Error text
            ); // End of Center
          } // End of if

          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) { // If no chats
            return Center( // Show no chats message
              child: Column( // Column for icon and text
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [ // Start children list
                  Icon( // Chat icon
                    Icons.chat_bubble_outline, // Icon type
                    size: 64, // Icon size
                    color: Colors.grey[400], // Icon color
                  ), // End of Icon
                  const SizedBox(height: 16), // Spacing
                  Text( // No chats text
                    'No chats available', // Text content
                    style: TextStyle( // Text style
                      fontSize: 18, // Font size
                      color: Colors.grey[600], // Text color
                    ), // End of TextStyle
                  ), // End of Text
                ], // End of children list
              ), // End of Column
            ); // End of Center
          } // End of if

          final chats = chatSnapshot.data!.docs; // Get chat documents
          return ListView.builder( // Build chat list
            itemCount: chats.length, // Number of chats
            itemBuilder: (context, index) { // Build each chat
              final chat = chats[index].data() as Map<String, dynamic>; // Chat data
              final participants = List<String>.from(chat['participants']); // List of participants
              final otherUserId = participants.firstWhere( // Find other user
                (id) => id != currentUser.uid, // Not current user
                orElse: () => '', // Default to empty
              ); // End of firstWhere
              if (otherUserId.isEmpty) { // If no other user
                return const SizedBox.shrink(); // Return empty widget
              } // End of if

              return StreamBuilder<DocumentSnapshot>( // Stream other user data
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .snapshots(), // Listen to user data
                builder: (context, userSnapshot) { // Build user info
                  if (!userSnapshot.hasData) { // If no data
                    return const SizedBox.shrink(); // Return empty widget
                  } // End of if

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?; // User data
                  if (userData == null) { // If no user data
                    return const SizedBox.shrink(); // Return empty widget
                  } // End of if

                  final userName = userData['name'] ?? userData['email'] ?? 'User'; // Get user name
                  final lastMessage = chat['lastMessage'] ?? ''; // Get last message
                  final lastMessageTime = chat['lastMessageTime'] != null
                      ? DateTime.parse(chat['lastMessageTime'])
                      : DateTime.now(); // Get last message time

                  return Card( // Chat card
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Card margin
                    elevation: 0, // No elevation
                    shape: RoundedRectangleBorder( // Card shape
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      side: BorderSide(color: Colors.grey[200]!), // Border color
                    ), // End of RoundedRectangleBorder
                    child: InkWell( // Make card tappable
                      onTap: () { // On tap
                        Navigator.of(context).push( // Navigate to chat room
                          MaterialPageRoute( // Create route
                            builder: (context) => ChatRoomScreen( // Build chat room
                              chatRoomId: chats[index].id, // Chat room ID
                              otherUserName: userName, // Other user name
                            ), // End of ChatRoomScreen
                          ), // End of MaterialPageRoute
                        ); // End of push
                      }, // End of onTap
                      borderRadius: BorderRadius.circular(12), // Ripple border radius
                      child: Padding( // Add padding
                        padding: const EdgeInsets.all(12), // Padding value
                        child: Row( // Row for avatar and info
                          children: [ // Start children list
                            Container( // User avatar container
                              width: 50, // Width
                              height: 50, // Height
                              decoration: BoxDecoration( // Avatar decoration
                                color: Colors.blue, // Avatar color
                                borderRadius: BorderRadius.circular(25), // Rounded corners
                              ), // End of BoxDecoration
                              child: const Icon( // User icon
                                Icons.person, // Icon type
                                color: Colors.white, // Icon color
                                size: 30, // Icon size
                              ), // End of Icon
                            ), // End of Container
                            const SizedBox(width: 12), // Spacing
                            Expanded( // Expand info
                              child: Column( // Column for name and message
                                crossAxisAlignment: CrossAxisAlignment.start, // Align start
                                children: [ // Start children list
                                  Row( // Row for name and time
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between
                                    children: [ // Start children list
                                      Text( // User name
                                        userName, // Name
                                        style: const TextStyle( // Text style
                                          fontSize: 16, // Font size
                                          fontWeight: FontWeight.bold, // Bold
                                        ), // End of TextStyle
                                      ), // End of Text
                                      Text( // Last message time
                                        _formatTime(lastMessageTime), // Format time
                                        style: TextStyle( // Text style
                                          fontSize: 12, // Font size
                                          color: Colors.grey[600], // Text color
                                        ), // End of TextStyle
                                      ), // End of Text
                                    ], // End of children list
                                  ), // End of Row
                                  const SizedBox(height: 4), // Spacing
                                  Text( // Last message
                                    lastMessage, // Message text
                                    maxLines: 1, // One line
                                    overflow: TextOverflow.ellipsis, // Ellipsis overflow
                                    style: TextStyle( // Text style
                                      color: Colors.grey[600], // Text color
                                    ), // End of TextStyle
                                  ), // End of Text
                                ], // End of children list
                              ), // End of Column
                            ), // End of Expanded
                          ], // End of children list
                        ), // End of Row
                      ), // End of Padding
                    ), // End of InkWell
                  ); // End of Card
                }, // End of builder
              ); // End of StreamBuilder
            }, // End of itemBuilder
          ); // End of ListView.builder
        }, // End of builder
      ), // End of StreamBuilder
    ); // End of Scaffold
  } // End of build method

  String _formatTime(DateTime time) { // Format time for last message
    final now = DateTime.now(); // Get current time
    final difference = now.difference(time); // Time difference

    if (difference.inDays > 0) { // If days ago
      return '${difference.inDays}d ago'; // Return days ago
    } else if (difference.inHours > 0) { // If hours ago
      return '${difference.inHours}h ago'; // Return hours ago
    } else if (difference.inMinutes > 0) { // If minutes ago
      return '${difference.inMinutes}m ago'; // Return minutes ago
    } else { // Just now
      return 'Just now'; // Return just now
    } // End of if-else
  } // End of _formatTime
} // End of ChatTab class 