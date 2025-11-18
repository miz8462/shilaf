import 'dart:async';

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
    AsyncNotifierProvider<AchievementNotifier, DailyAchievement?>(
        AchievementNotifier.new);

/// 達成記録の作成を実行するNotifier
class AchievementNotifier extends AsyncNotifier<DailyAchievement?> {
  late final DailyAchievementRepository _repository;
  late final StreaksRepository _streakRepository;

  /// build() は初期化処理を行う場所
  /// - Provider から依存を取得
  /// - 初期値を返す（ここでは null）
  @override
  FutureOr<DailyAchievement?> build() {
    _repository = ref.watch(dailyAchievementRepositoryProvider);
    _streakRepository = ref.watch(streakRepositoryProvider);
    return null;
  }

  /// 今日の達成記録を作成
  /// - 1日1回の制限をチェック
  /// - streaks テーブルの last_achievement_date を更新
  /// - 関連プロバイダーを invalidate して再取得
  Future<void> createTodayAchievement() async {
    // ローディング状態に更新
    state = const AsyncLoading();

    // guard() で例外をキャッチしつつ AsyncValue を更新
    state = await AsyncValue.guard(() async {
      // 既に今日の達成記録があるかチェック
      final hasToday = await _repository.hasTodayAchievement();
      if (hasToday) {
        throw Exception('今日は既に達成記録が登録されています');
      }

      // 現在の streak を取得
      final currentStreak = await _streakRepository.getCurrentStreak();
      if (currentStreak == null) {
        throw Exception('継続記録が見つかりません');
      }

      // 達成記録を作成
      final achievement = await _repository.createTodayAchievement(
        streakId: currentStreak.id,
      );

      // streaks テーブルの last_achievement_date を更新
      final today = DateTime.now();
      await _streakRepository.updateLastAchievementDate(today);

      // 関連プロバイダーを再取得
      ref.invalidate(todayAchievementProvider);
      ref.invalidate(hasTodayAchievementProvider);
      ref.invalidate(currentStreakProvider);

      return achievement;
    });
  }
}
