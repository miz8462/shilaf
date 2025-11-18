import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

/// 認証リポジトリのプロバイダー
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 認証状態を監視するプロバイダー
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// 現在のユーザー情報を取得するプロバイダー
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => null,
  );
});

/// 認証アクションを管理するプロバイダー
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

/// 認証アクションを実行するNotifier
class AuthNotifier extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<void> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return null; // 初期値
  }

  /// メールアドレスでサインアップ
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );
    });
  }

  /// メールアドレスでサインイン
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
    });
  }

  /// Googleでサインイン
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithGoogle();
    });
  }

  /// サインアウト
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
    });
  }

  /// パスワードリセット
  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.resetPassword(email);
    });
  }
}
