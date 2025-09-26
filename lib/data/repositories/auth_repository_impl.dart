/*
 * lib/data/repositories/auth_repository_impl.dart
 */
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/firebase_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Stream<AppUser?> authStateChanges() => _ds.authState().map((u) => u?.toEntity());

  @override
  Future<AppUser?> currentUser() async => _ds.current()?.toEntity();

  @override
  Future<AppUser> registerWithEmail(String email, String password) async =>
      (await _ds.registerEmail(email, password)).toEntity();

  @override
  Future<AppUser> signInWithEmail(String email, String password) async =>
      (await _ds.signInEmail(email, password)).toEntity();

  @override
  Future<AppUser> signInWithGoogle() async =>
      (await _ds.signInGoogle()).toEntity();

  @override
  Future<void> signOut() => _ds.signOut();
}
