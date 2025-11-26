import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/achievements/providers/achievement_provider.dart';

class AchievementSection extends ConsumerWidget {
  const AchievementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTodayAchievementAsync = ref.watch(hasTodayAchievementProvider);
    final achievementNotifier = ref.watch(achievementNotifierProvider.notifier);
    final achievementState = ref.watch(achievementNotifierProvider);

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
      // FIXME: ボタンを押したあとに表示されるカードがもとより下に表示される
      data: (hasToday) {
        final isLoading = achievementState.isLoading;

        if (hasToday) {
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
                  const Text(
                    '今日の達成を記録済み',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () async {
                    await achievementNotifier.createTodayAchievement();
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
              backgroundColor:
                  isLoading ? AppColors.textDisabled : AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          );
        }
      },
    );
  }
}
