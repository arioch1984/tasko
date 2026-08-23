import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tasko/core/constants.dart';

class AuthState {
  const AuthState({
    this.account,
    this.isLoading = false,
    this.error,
  });

  final GoogleSignInAccount? account;
  final bool isLoading;
  final String? error;

  bool get isSignedIn => account != null;

  AuthState copyWith({
    GoogleSignInAccount? account,
    bool clearAccount = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      account: clearAccount ? null : (account ?? this.account),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._googleSignIn) : super(const AuthState()) {
    _restore();
  }

  final GoogleSignIn _googleSignIn;

  Future<void> _restore() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleSignIn.signInSilently();
      state = AuthState(account: account, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = AuthState(account: account, isLoading: false);
    } catch (e, st) {
      debugPrint('Sign-in failed: $e\n$st');
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    state = const AuthState();
  }

  Future<String?> accessToken() async {
    final account = state.account ?? await _googleSignIn.signInSilently();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.accessToken;
  }
}

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  final macosClientId = AppConstants.macosGoogleClientId;
  final onMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  return GoogleSignIn(
    scopes: const [AppConstants.tasksScope],
    clientId: onMac && macosClientId.isNotEmpty ? macosClientId : null,
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(googleSignInProvider));
});
