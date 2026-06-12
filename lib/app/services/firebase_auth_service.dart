import 'package:firebase_auth/firebase_auth.dart' ;

import '../models/user_data.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  bool _isInitialized;

  FirebaseAuthService({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _isInitialized = false;

  UserData _userDataFromFirebaseUser(User user) {
    if (user == null) {
      return null;
    }
    return UserData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  Stream<UserData> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userDataFromFirebaseUser);
  }

  Future<UserData> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userDataFromFirebaseUser(authResult.user);
  }

  Future<UserData> signInWithGoogle() async {
    //Firebase-native popup flow. The google_sign_in plugin's web
    //implementation depends on Google's gapi platform.js, deprecated
    //since March 2023 and liable to be shut off.
    try {
      final authResult =
          await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      return _userDataFromFirebaseUser(authResult.user);
    } on FirebaseAuthException catch (e) {
      //e.g. popup closed by user - treat as a cancelled sign-in
      print("Google sign-in did not complete: " + e.code);
      return null;
    }
  }

  Future<void> signOut() async {
    _isInitialized = false;
    return _firebaseAuth.signOut();
  }

  UserData currentUser() {
    final userData = _firebaseAuth.currentUser;
    return _userDataFromFirebaseUser(userData);
  }

  bool get isInitialized => _isInitialized;

  markInitialized(){
    _isInitialized = true;
  }
}
