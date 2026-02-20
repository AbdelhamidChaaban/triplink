// Importing Firebase Authentication package for managing user authentication
import 'package:firebase_auth/firebase_auth.dart';

// Importing Firestore package for storing and retrieving user data
import 'package:cloud_firestore/cloud_firestore.dart';

// Importing the UserModel class, which represents user data structure
import '../models/user_model.dart';

// Defining a service class for authentication and user management
// This class handles user sign-in, sign-up, sign-out, and user information retrieval
class AuthService {
  // Creating an instance of Firebase Authentication for handling authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Creating an instance of Firestore for storing user data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter to retrieve the currently signed-in user (if any)
  User? get currentUser => _auth.currentUser;

  // Stream that listens for authentication state changes (sign-in/sign-out events)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Function to sign up a new user with email and password
  Future<UserModel> signUp({
    required String email, // User's email
    required String password, // User's password
    required String name, // User's name
    required String phoneNumber, // User's phone number
    required bool isDriver, // Boolean flag indicating if the user is a driver
  }) async {
    try {
      // Creating a new user account in Firebase Authentication
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieving the created user from the result
      final User? user = result.user;

      // If user creation failed, throwing an exception
      if (user == null) throw Exception('Failed to create user');

      // Creating a UserModel object with the user details
      final UserModel userModel = UserModel(
        id: user.uid, // Assigning Firebase-generated unique user ID
        name: name, // Assigning user-provided name
        email: email, // Assigning user-provided email
        phoneNumber: phoneNumber, // Assigning user-provided phone number
        isDriver: isDriver, // Assigning driver status
        createdAt: DateTime.now(), // Storing account creation timestamp
      );

      // Saving the user data into Firestore under the 'users' collection
      await _firestore.collection('users').doc(user.uid).set(userModel.toJson());

      return userModel; // Returning the created user model
    } catch (e) {
      // Catching any errors and throwing an exception with error details
      throw Exception('Failed to sign up: $e');
    }
  }

  // Function to sign in an existing user with email and password
  Future<UserModel> signIn({
    required String email, // User's email
    required String password, // User's password
  }) async {
    try {
      // Signing in user using Firebase Authentication
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieving the signed-in user from the result
      final User? user = result.user;

      // If sign-in failed, throwing an exception
      if (user == null) throw Exception('Failed to sign in');

      // Fetching user data from Firestore based on user ID
      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      // Converting retrieved Firestore data into a UserModel object and returning it
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Catching any errors and throwing an exception with error details
      throw Exception('Failed to sign in: $e');
    }
  }

  // Function to sign out the currently logged-in user
  Future<void> signOut() async {
    try {
      // Signing out the user from Firebase Authentication
      await _auth.signOut();
    } catch (e) {
      // Catching any errors and throwing an exception with error details
      throw Exception('Failed to sign out: $e');
    }
  }

  // Function to retrieve user data from Firestore based on user ID
  Future<UserModel> getUserData(String userId) async {
    try {
      // Fetching user document from Firestore based on user ID
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      // Converting retrieved Firestore data into a UserModel object and returning it
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Catching any errors and throwing an exception with error details
      throw Exception('Failed to get user data: $e');
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    try {
      // Updating user document in Firestore with new user data
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      // Catching any errors and throwing an exception with error details
      throw Exception('Failed to update user data: $e');
    }
  }
}