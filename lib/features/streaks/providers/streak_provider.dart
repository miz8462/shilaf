import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/streaks/data/models/streak_model.dart';
import 'package:shilaf/features/streaks/data/streaks_repository.dart';

/// 継続日数リポジトリのプロバイダー
final streakRepositoryProvider = Provider<StreaksRepository>((ref) {
  return StreaksRepository();
});

/// 現在の継続記録を取得するプロバイダー
final currentStreakProvider = FutureProvider<StreakModel?>((ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  return await repository.getCurrentStreak();
});

/// 現在の継続日数を取得するプロバイダー（便利メソッド）
/// StreakModelから日数だけを取り出す
final currentStreakDaysProvider = FutureProvider<int>((ref) async {
  final streak = await ref.watch(currentStreakProvider.future);
  if (streak == null) {
    return 0;
  }
  // 最新の日数を計算して返す
  return streak.calculateDaysFromStart();
});

/// 継続記録の作成・更新を管理するプロバイダー
final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, AsyncValue<StreakModel?>>((ref) {
  final repository = ref.watch(streakRepositoryProvider);
  return StreakNotifier(repository, ref);
});

/// 継続記録の作成・更新を実行するNotifier
class StreakNotifier extends StateNotifier<AsyncValue<StreakModel?>> {
  final StreaksRepository _repository;
  final Ref _ref;

  StreakNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// 初回の継続記録を作成（初期設定時）
  Future<void> createInitialStreak({
    required DateTime sobrietyStartDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final streak = await _repository.createInitialStreak(
        sobrietyStartDate: sobrietyStartDate,
      );

      // 作成後、currentStreakProviderを再取得させる
      _ref.invalidate(currentStreakProvider);
      _ref.invalidate(currentStreakDaysProvider);

      return streak;
    });
  }

  /// 継続日数を更新（再計算）
  Future<void> updateStreakDays() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final streak = await _repository.updateStreakDays();

      // 更新後、プロバイダーを再取得
      _ref.invalidate(currentStreakProvider);
      _ref.invalidate(currentStreakDaysProvider);

      return streak;
    });
  }

  /// 継続開始日を変更
  Future<void> updateStartDate(DateTime newStartDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final streak = await _repository.updateStartDate(newStartDate);

      // 更新後、プロバイダーを再取得
      _ref.invalidate(currentStreakProvider);
      _ref.invalidate(currentStreakDaysProvider);

      return streak;
    });
  }

  /// 継続記録をリセット
  Future<void> resetStreak(DateTime newStartDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final streak = await _repository.resetStreak(newStartDate);

      // リセット後、プロバイダーを再取得
      _ref.invalidate(currentStreakProvider);
      _ref.invalidate(currentStreakDaysProvider);

      return streak;
    });
  }
}
