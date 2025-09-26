/*
 * lib/domain/entities/app_user.dart
 */
class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AppUser.anonymous() => const AppUser(id: 'anonymous');

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: (map['id'] ?? '') as String,
        email: map['email'] as String?,
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
      );

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ displayName.hashCode ^ photoUrl.hashCode;
}
