import 'dart:async';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Mock auth repository for development/testing.
/// TODO: Replace with FirebaseAuthRepository once Firebase is configured.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _authStateController = StreamController<AuthUser?>.broadcast(
      onListen: () => _authStateController.add(_currentUser),
    );
  }

  late final StreamController<AuthUser?> _authStateController;
  AuthUser? _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 610)); // F15 delay
    
    // Mock validation
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    final user = AuthUser(
      uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      isEmailVerified: true,
    );

    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 610));

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    final user = AuthUser(
      uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      isEmailVerified: false,
    );

    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 610));

    final user = AuthUser(
      uid: 'mock-google-uid-${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      displayName: 'Mock User',
      photoUrl: 'https://i.pravatar.cc/150?img=3',
      isEmailVerified: true,
    );

    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 233)); // F13 delay
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 377)); // F14 delay
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 377));
    // In mock, instantly verify
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isEmailVerified: true);
      _authStateController.add(_currentUser);
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
