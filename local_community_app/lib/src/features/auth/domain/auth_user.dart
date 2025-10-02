import 'package:flutter/foundation.dart';

/// Domain model for authenticated user (decoupled from Firebase).
@immutable
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      isEmailVerified.hashCode;
}
