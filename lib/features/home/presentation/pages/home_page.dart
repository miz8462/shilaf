import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/achievements/providers/achievement_provider.dart';
import 'package:shilaf/features/auth/providers/auth_provider.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';
import 'package:shilaf/features/streaks/utils/savings_calculator.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 日付をフォーマット（例: 2024年1月15日）
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザーデータを取得
    final userDataAsync = ref.watch(currentUserDataProvider);
    // 継続日数を取得
    final streakAsync = ref.watch(currentStreakProvider);

    // ホーム画面表示時に継続日数をDBに同期
    ref.listen(currentStreakProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // バックグラウンドで更新（エラーは無視）
        Future.microtask(() {
          ref.read(streakNotifierProvider.notifier).updateStreakDays();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shilaf'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 下に引っ張って更新
          ref.invalidate(currentUserDataProvider);
          ref.invalidate(currentStreakProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ユーザー情報セクション
              userDataAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'エラー: $error',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (user) {
                  if (user == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('ユーザー情報が見つかりません'),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // プロフィールアイコン
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ユーザー名
                          Text(
                            'こんにちは、${user.username}さん',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // 登録日
                          Text(
                            '登録日: ${_formatDate(user.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 継続日数セクション
              streakAsync.when(
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'エラー: $error',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (streak) {
                  if (streak == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('継続記録が見つかりません'),
                      ),
                    );
                  }

                  // 最新の継続日数を計算
                  final days = streak.calculateDaysFromStart() + 1;

                  return Card(
                    color: AppColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // 継続日数（大きく）
                          Text(
                            '$days',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '日目',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 区切り線
                          Container(
                            height: 2,
                            width: 100,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 24),
                          // 開始日
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatDate(streak.sobrietyStartDate)} 〜',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 節約額表示カード
              Consumer(
                builder: (context, ref, child) {
                  final userDataAsync = ref.watch(currentUserDataProvider);
                  final streakAsync = ref.watch(currentStreakProvider);

                  return userDataAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (user) {
                      if (user == null) {
                        return const SizedBox.shrink();
                      }

                      return streakAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (error, stack) => const SizedBox.shrink(),
                        data: (streak) {
                          if (streak == null) {
                            return const SizedBox.shrink();
                          }

                          // 継続日数を計算
                          final days = streak.calculateDaysFromStart() + 1;
                          // 総節約額を計算
                          final totalSavings =
                              SavingsCalculator.calculateTotalSavings(
                            days: days,
                            weeklyCost: user.weeklyDrinkingCost,
                          );

                          // 週あたりのコストが設定されていない場合は表示しない
                          if (user.weeklyDrinkingCost == null ||
                              user.weeklyDrinkingCost! <= 0) {
                            return const SizedBox.shrink();
                          }

                          // 1日あたりの節約額を計算
                          final dailySavings = SavingsCalculator.calculateDailySavings(
                            user.weeklyDrinkingCost,
                          );

                          return Card(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.savings,
                                        color: AppColors.secondary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '累計節約額',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    SavingsCalculator.formatAmount(
                                        totalSavings),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '1日あたり ${SavingsCalculator.formatAmount(dailySavings)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '（週あたり ${SavingsCalculator.formatAmount(user.weeklyDrinkingCost!)}）',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // 達成ボタン
              Consumer(
                builder: (context, ref, child) {
                  final hasTodayAchievementAsync =
                      ref.watch(hasTodayAchievementProvider);
                  final achievementNotifier =
                      ref.watch(achievementNotifierProvider.notifier);
                  final achievementState =
                      ref.watch(achievementNotifierProvider);

                  // 達成記録の状態変化を監視してスナックバーを表示
                  ref.listen(achievementNotifierProvider, (previous, next) {
                    if (next.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            next.error.toString().replaceAll('Exception: ', ''),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (previous?.isLoading == true &&
                        next.hasValue &&
                        next.value != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('達成記録を登録しました！'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    }
                  });

                  return hasTodayAchievementAsync.when(
                    loading: () => ElevatedButton.icon(
                      onPressed: null,
                      icon: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      label: const Text('読み込み中...'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.textDisabled,
                      ),
                    ),
                    error: (error, stack) => ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.error_outline),
                      label: const Text('エラーが発生しました'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.error,
                      ),
                    ),
                    data: (hasToday) {
                      final isLoading = achievementState.isLoading;

                      if (hasToday) {
                        // 今日の達成記録が既にある場合
                        return Card(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '今日の達成を記録済み',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // 今日の達成記録がない場合
                        return ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await achievementNotifier
                                      .createTodayAchievement();
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(isLoading ? '登録中...' : '今日の達成を記録'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isLoading
                                ? AppColors.textDisabled
                                : AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
