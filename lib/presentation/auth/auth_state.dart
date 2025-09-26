// lib/presentation/auth/auth_state.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Trạng thái để UI hiển thị tiến trình/lỗi
enum AuthStatus { idle, loading, error }

class AuthState extends ChangeNotifier {
  final FirebaseAuth _auth;
  GoogleSignIn? _google; // mobile only

  AuthStatus _status = AuthStatus.idle;
  String? _error;
  User? _user;
  StreamSubscription<User?>? _sub;

  AuthState({
    FirebaseAuth? auth,
    GoogleSignIn? google,
  }) : _auth = auth ?? FirebaseAuth.instance {
    // google_sign_in chỉ dùng cho Android/iOS
    if (!kIsWeb) {
      _google = google ?? GoogleSignIn(scopes: const ['email']);
    }
  }

  // getters
  AuthStatus get status => _status;
  String? get error => _error;
  User? get user => _user;
  bool get isSignedIn => _user != null;

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setIdle() {
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void _setError(Object e) {
    _status = AuthStatus.error;
    _error = e.toString();
    notifyListeners();
  }

  /// Lắng nghe đăng nhập/đăng xuất
  void bindAuthStream() {
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((u) {
      _user = u;
      if (_status != AuthStatus.loading) {
        _status = AuthStatus.idle;
      }
      notifyListeners();
    });
  }

  /// Đăng ký email/password
  Future<void> registerWithEmail(String email, String password) async {
    _setLoading();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng nhập email/password
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng nhập Google
  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      if (kIsWeb) {
        // Web: dùng popup trực tiếp với FirebaseAuth
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        await _auth.signInWithPopup(provider);
      } else {
        // Android/iOS: dùng google_sign_in 6.2.1
        final gUser = await _google!.signIn(); // mở chọn tài khoản
        if (gUser == null) {
          _setIdle(); // user hủy
          return;
        }
        final gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng xuất – cả FirebaseAuth lẫn GoogleSignIn
  Future<void> signOut() async {
    _setLoading();
    try {
      await _auth.signOut();
      if (!kIsWeb && _google != null) {
        // Không sao nếu chưa đăng nhập Google; ignore lỗi nhỏ
        try {
          await _google!.signOut();
          await _google!.disconnect(); // lần sau hiện dialog chọn tài khoản
        } catch (_) {}
      }
      _setIdle();
    } catch (e) {
      _setError(e);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
