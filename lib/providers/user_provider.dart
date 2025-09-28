import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for the auth state changes stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider for the user data from Firestore
final userProvider = StateNotifierProvider<UserDataNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final user = ref.watch(authStateProvider).value;
  return UserDataNotifier(authService, user?.uid);
});

class UserDataNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final String? _uid;

  UserDataNotifier(this._authService, this._uid) : super(const AsyncValue.loading()) {
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    if (_uid == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final user = await _authService.getUserFromFirestore(_uid!);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _authService.saveUserToFirestore(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}