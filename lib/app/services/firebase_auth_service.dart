import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

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
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    return _userDataFromFirebaseUser(authResult.user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  UserData currentUser() {
    final userData = _firebaseAuth.currentUser;
    return _userDataFromFirebaseUser(userData);
  }
}
