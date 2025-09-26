import "package:firebase_auth/firebase_auth.dart";

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  AuthRemoteDataSource({ FirebaseAuth? auth }) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> authState() => _auth.authStateChanges();
  User? current() => _auth.currentUser;

  // Email/Password
  Future<User> registerEmail(String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    final user = cred.user;
    if (user == null) { throw FirebaseAuthException(code: "no-user", message: "No user returned"); }
    return user;
  }

  Future<User> signInEmail(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    final user = cred.user;
    if (user == null) { throw FirebaseAuthException(code: "no-user", message: "No user returned"); }
    return user;
  }

  // Google Sign-In: dùng trực tiếp GoogleAuthProvider, không cần package google_sign_in
  Future<User> signInGoogle() async {
    final userCred = await _auth.signInWithProvider(GoogleAuthProvider());
    final user = userCred.user;
    if (user == null) { throw FirebaseAuthException(code: "no-user", message: "No user returned"); }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
