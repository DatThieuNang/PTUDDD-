/*
 * lib/data/models/firebase_user_mapper.dart
 */
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';

extension FirebaseUserX on User {
  AppUser toEntity() => AppUser(
        id: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoURL,
      );
}
