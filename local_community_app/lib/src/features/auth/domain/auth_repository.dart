import 'auth_user.dart';

/// Repository interface for authentication operations.
/// Implementations can use Firebase, Supabase, or mock for testing.
abstract class AuthRepository {
  /// Stream of auth state changes.
  Stream<AuthUser?> authStateChanges();

  /// Current authenticated user (sync).
  AuthUser? get currentUser;

  /// Sign in with email/password.
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create account with email/password.
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google OAuth.
  Future<AuthUser> signInWithGoogle();

  /// Sign out current user.
  Future<void> signOut();

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification.
  Future<void> sendEmailVerification();
}
