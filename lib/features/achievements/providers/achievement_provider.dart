import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/achievements/data/daily_achievement_repository.dart';
import 'package:shilaf/features/achievements/data/models/daily_achievement_model.dart';
import 'package:shilaf/features/streaks/data/streaks_repository.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

/// 達成記録リポジトリのプロバイダー
final dailyAchievementRepositoryProvider =
    Provider<DailyAchievementRepository>((ref) {
  return DailyAchievementRepository();
});

/// 今日の達成記録を取得するプロバイダー
final todayAchievementProvider = FutureProvider<DailyAchievement?>((ref) async {
  final repository = ref.watch(dailyAchievementRepositoryProvider);
  return await repository.getTodayAchievement();
});

/// 今日の達成記録が存在するかチェックするプロバイダー
final hasTodayAchievementProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(dailyAchievementRepositoryProvider);
  return await repository.hasTodayAchievement();
});

/// 達成記録の作成を管理するプロバイダー
final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, AsyncValue<DailyAchievement?>>(
        (ref) {
  final repository = ref.watch(dailyAchievementRepositoryProvider);
  final streakRepository = ref.watch(streakRepositoryProvider);
  return AchievementNotifier(repository, streakRepository, ref);
});

/// 達成記録の作成を実行するNotifier
class AchievementNotifier extends StateNotifier<AsyncValue<DailyAchievement?>> {
  final DailyAchievementRepository _repository;
  final StreaksRepository _streakRepository;
  final Ref _ref;

  AchievementNotifier(this._repository, this._streakRepository, this._ref)
      : super(const AsyncValue.data(null));

  /// 今日の達成記録を作成
  /// 1日1回の制限をチェックし、streaksテーブルのlast_achievement_dateも更新
  Future<void> createTodayAchievement() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 既に今日の達成記録があるかチェック
      final hasToday = await _repository.hasTodayAchievement();
      if (hasToday) {
        throw Exception('今日は既に達成記録が登録されています');
      }

      // 現在のstreakを取得してstreak_idを取得
      final currentStreak = await _streakRepository.getCurrentStreak();
      if (currentStreak == null) {
        throw Exception('継続記録が見つかりません');
      }

      // 達成記録を作成
      final achievement = await _repository.createTodayAchievement(
        streakId: currentStreak.id,
      );

      // streaksテーブルのlast_achievement_dateを更新
      final today = DateTime.now();
      await _streakRepository.updateLastAchievementDate(today);

      // 更新後、プロバイダーを再取得
      _ref.invalidate(todayAchievementProvider);
      _ref.invalidate(hasTodayAchievementProvider);
      _ref.invalidate(currentStreakProvider);

      return achievement;
    });
  }
}
