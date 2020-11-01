import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:q_and_a/services/database.dart';

class AuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DatabaseService databaseService = DatabaseService();

  // create User object
  UserModel _userFromFirebaseUser(auth.User user) {
    return user != null ? UserModel(uid: user.uid, displayName: user.displayName, email: user.email, photoUrl: user.photoURL) : null;
  }

  // Auth change stream of User
  Stream<UserModel> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with google
  Future signInWithGoogle() async {
    try {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken);
      final auth.User user = (await _auth.signInWithCredential(credential)).user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    _firebaseMessaging.getToken().then((value) async {
      databaseService.removeUserToken(userId: _auth.currentUser.uid, token: value);
      try {
        return await _auth.signOut().then((value) {
          googleSignIn.signOut();
        });
      } catch (e) {
        print(e.toString());
        return null;
      }
    });
  }

}