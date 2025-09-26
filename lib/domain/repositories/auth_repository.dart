/*
 * lib/domain/repositories/auth_repository.dart
 */
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser?> currentUser();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> registerWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}
