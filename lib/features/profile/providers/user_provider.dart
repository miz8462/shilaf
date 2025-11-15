import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/profile/data/models/user_model.dart';
import 'package:shilaf/features/profile/data/user_repository.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

/// 現在のユーザーデータを取得するプロバイダー
/// FutureProvider: 非同期でデータを取得
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getCurrentUser();
});

/// 初期設定が完了しているかのフラグ
/// ルーティングの判定に使用
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.hasCompletedOnboarding();
});

/// ユーザー情報の作成・更新を管理するプロバイダー
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository, ref);
});

/// ユーザー情報の作成・更新を実行するNotifier
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UsersRepository _repository;
  final Ref _ref;

  UserNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// 新規ユーザーを作成（初期設定時）
  Future<void> createUser({
    required String username,
    String? bio,
    int? weeklyDrinkingCost,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.createUser(
        username: username,
        bio: bio,
        weeklyDrinkingCost: weeklyDrinkingCost,
      );

      // 作成後、currentUserDataProviderを再取得させる
      _ref.invalidate(currentUserDataProvider);
      _ref.invalidate(hasCompletedOnboardingProvider);

      return user;
    });
  }

  /// ユーザー情報を更新（プロフィール編集時）
  Future<void> updateUser({
    String? username,
    String? bio,
    String? avatarUrl,
    int? weeklyDrinkingCost,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.updateUser(
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
        weeklyDrinkingCost: weeklyDrinkingCost,
      );

      // 更新後、currentUserDataProviderを再取得させる
      _ref.invalidate(currentUserDataProvider);

      return user;
    });
  }

  /// ユーザー名の重複チェック
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await _repository.isUsernameAvailable(username);
    } catch (e) {
      return false;
    }
  }
}
