import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Provider for auth repository (mock for now, Firebase later).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Provider for current auth state stream.
final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Provider for current user (sync).
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

/// Auth service with business logic.
class AuthService {
  AuthService(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _authRepository.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await _authRepository.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await _authRepository.sendEmailVerification();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authRepositoryProvider));
});
