import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/home/utils/date_formatter.dart';
import 'package:shilaf/features/streaks/data/models/streak_model.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streakAsync,
    required this.onResetPressed,
  });

  final AsyncValue<StreakModel?> streakAsync;
  final VoidCallback onResetPressed;

  @override
  Widget build(BuildContext context) {
    return streakAsync.when(
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

        final days = streak.calculateDaysFromStart() + 1;

        return Card(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
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
                Container(
                  height: 2,
                  width: 100,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
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
                      '${formatJapaneseDate(streak.sobrietyStartDate)} 〜',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onResetPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('継続をリセット'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
