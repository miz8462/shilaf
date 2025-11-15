import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/auth/providers/auth_provider.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

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

              // 達成ボタン（Phase 4で実装予定）
              ElevatedButton.icon(
                onPressed: null, // 今は無効
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('今日の達成を記録'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secondary,
                  disabledBackgroundColor: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '※ 達成記録機能は近日実装予定',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
