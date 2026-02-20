import 'package:flutter/material.dart'; // Import Flutter material design library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../../../services/auth_service.dart'; // Import authentication service

class ChatRoomScreen extends StatefulWidget { // Define ChatRoomScreen widget
  final String chatRoomId; // Chat room ID
  final String otherUserName; // Name of the other user
  const ChatRoomScreen({super.key, required this.chatRoomId, required this.otherUserName}); // Constructor

  @override // Override createState method
  State<ChatRoomScreen> createState() => _ChatRoomScreenState(); // Create state for ChatRoomScreen
} // End of ChatRoomScreen class

class _ChatRoomScreenState extends State<ChatRoomScreen> { // Define state for ChatRoomScreen
  final TextEditingController _messageController = TextEditingController(); // Controller for message input
  final ScrollController _scrollController = ScrollController(); // Controller for scrolling messages
  final currentUser = AuthService().currentUser; // Get current user

  void _sendMessage() async { // Send a message
    final text = _messageController.text.trim(); // Get trimmed message text(trim to remove spaces)
    if (text.isEmpty) return; // Do nothing if message is empty

    final now = DateTime.now(); // Get current time
    await FirebaseFirestore.instance.collection('chats/${widget.chatRoomId}/messages').add({ // Add message to Firestore
      'text': text, // Message text
      'createdAt': now.toIso8601String(), // Message creation time
      'senderId': currentUser?.uid, // Sender user ID
    }); // End of add

    // Update last message in chat room
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId).update({ // Update chat room
      'lastMessage': text, // Last message text
      'lastMessageTime': now.toIso8601String(), // Last message time
    }); // End of update

    _messageController.clear(); // Clear message input
    _scrollController.animateTo( // Scroll to top
      0.0, // Scroll position
      duration: const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeOut, // Animation curve
    ); // End of animateTo
  } // End of _sendMessage

  @override // Override build method
  Widget build(BuildContext context) { // Build widget
    return Scaffold( // Return Scaffold widget
      appBar: AppBar( // App bar
        title: Row( // Row for title
          children: [ // Start children list
            const CircleAvatar( // User avatar
              backgroundColor: Colors.blue, // Avatar color
              child: Icon(Icons.person, color: Colors.white), // Person icon
            ), // End of CircleAvatar
            const SizedBox(width: 8), // Spacing
            Text( // Display other user's name
              widget.otherUserName, // Other user's name
              style: const TextStyle(fontSize: 16), // Text style
            ), // End of Text
          ], // End of children list
        ), // End of Row
      ), // End of AppBar
      body: Column( // Main column
        children: [ // Start children list
          Expanded( // Expand to fill space
            child: StreamBuilder<QuerySnapshot>( // Stream messages
              stream: FirebaseFirestore.instance
                  .collection('chats/${widget.chatRoomId}/messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(), // Listen to messages
              builder: (context, snapshot) { // Build message list
                if (!snapshot.hasData) { // If no data
                  return const Center(child: CircularProgressIndicator()); // Show loading
                } // End of if
                final docs = snapshot.data!.docs; // Get message documents
                return ListView.builder( // Build message list
                  controller: _scrollController, // Assign scroll controller
                  reverse: true, // Show newest at bottom
                  padding: const EdgeInsets.all(16), // Add padding
                  itemCount: docs.length, // Number of messages
                  itemBuilder: (context, index) { // Build each message
                    final data = docs[index].data() as Map<String, dynamic>; // Message data
                    final isMe = data['senderId'] == currentUser?.uid; // Is this my message?
                    final messageTime = DateTime.parse(data['createdAt']); // Message time

                    return Padding( // Add padding
                      padding: const EdgeInsets.symmetric(vertical: 4), // Vertical padding
                      child: Row( // Row for message
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, // Align message
                        children: [ // Start children list
                          if (!isMe) ...[ // If not my message
                            const CircleAvatar( // Other user avatar
                              radius: 16, // Avatar size
                              backgroundColor: Colors.blue, // Avatar color
                              child: Icon(Icons.person, size: 16, color: Colors.white), // Person icon
                            ), // End of CircleAvatar
                            const SizedBox(width: 8), // Spacing
                          ], // End of if
                          Flexible( // Flexible container
                            child: Container( // Message bubble
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding
                              decoration: BoxDecoration( // Bubble decoration
                                color: isMe ? Colors.blue : Colors.grey[200], // Bubble color
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ), // End of BoxDecoration
                              child: Column( // Column for text and time
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align text
                                children: [ // Start children list
                                  Text( // Message text
                                    data['text'] ?? '', // Message content
                                    style: TextStyle( // Text style
                                      color: isMe ? Colors.white : Colors.black, // Text color
                                    ), // End of TextStyle
                                  ), // End of Text
                                  const SizedBox(height: 4), // Spacing
                                  Text( // Message time
                                    _formatTime(messageTime), // Format time
                                    style: TextStyle( // Text style
                                      fontSize: 10, // Font size
                                      color: isMe ? Colors.white70 : Colors.grey[600], // Text color
                                    ), // End of TextStyle
                                  ), // End of Text
                                ], // End of children list
                              ), // End of Column
                            ), // End of Container
                          ), // End of Flexible
                          if (isMe) ...[ // If my message
                            const SizedBox(width: 8), // Spacing
                            const CircleAvatar( // My avatar
                              radius: 16, // Avatar size
                              backgroundColor: Colors.blue, // Avatar color
                              child: Icon(Icons.person, size: 16, color: Colors.white), // Person icon
                            ), // End of CircleAvatar
                          ], // End of if
                        ], // End of children list
                      ), // End of Row
                    ); // End of Padding
                  }, // End of itemBuilder
                ); // End of ListView.builder
              }, // End of builder
            ), // End of StreamBuilder
          ), // End of Expanded
          Container( // Message input container
            padding: const EdgeInsets.all(8), // Padding
            decoration: BoxDecoration( // Box decoration
              color: Colors.white, // Background color
              boxShadow: [ // Box shadow
                BoxShadow( // Shadow
                  color: Colors.grey.withOpacity(0.2), // Shadow color
                  spreadRadius: 1, // Spread radius
                  blurRadius: 3, // Blur radius
                  offset: const Offset(0, -1), // Offset
                ), // End of BoxShadow
              ], // End of boxShadow
            ), // End of BoxDecoration
            child: Row( // Row for input and send button
              children: [ // Start children list
                Expanded( // Expand input field
                  child: TextField( // Message input field
                    controller: _messageController, // Assign controller
                    decoration: InputDecoration( // Input decoration
                      hintText: 'Type a message...', // Hint text
                      border: OutlineInputBorder( // Input border
                        borderRadius: BorderRadius.circular(25), // Rounded border
                        borderSide: BorderSide.none, // No border side
                      ), // End of OutlineInputBorder
                      filled: true, // Filled background
                      fillColor: Colors.black, // Fill color
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                    ), // End of InputDecoration
                  ), // End of TextField
                ), // End of Expanded
                const SizedBox(width: 8), // Spacing
                Container( // Send button container
                  decoration: const BoxDecoration( // Box decoration
                    shape: BoxShape.circle, // Circle shape
                    color: Colors.blue, // Button color
                  ), // End of BoxDecoration
                  child: IconButton( // Send button
                    icon: const Icon(Icons.send, color: Colors.white), // Send icon
                    onPressed: _sendMessage, // Send message on press
                  ), // End of IconButton
                ), // End of Container
              ], // End of children list
            ), // End of Row
          ), // End of Container
        ], // End of children list
      ), // End of Column
    ); // End of Scaffold
  } // End of build method

  String _formatTime(DateTime time) { // Format message time
    final now = DateTime.now(); // Get current time
    final difference = now.difference(time); // Time difference

    if (difference.inDays > 0) { // If more than a day ago
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}'; // Return hour:minute
    } else if (difference.inHours > 0) { // If more than an hour ago
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}'; // Return hour:minute
    } else if (difference.inMinutes > 0) { // If more than a minute ago
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}'; // Return hour:minute
    } else { // Just now
      return 'Now'; // Return 'Now'
    } // End of if-else
  } // End of _formatTime
} // End of _ChatRoomScreenState class 