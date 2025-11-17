import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/profile/data/models/user_model.dart';
import 'package:shilaf/features/streaks/data/models/streak_model.dart';
import 'package:shilaf/features/streaks/utils/savings_calculator.dart';

class SavingsCard extends StatelessWidget {
  const SavingsCard({
    super.key,
    required this.userAsync,
    required this.streakAsync,
  });

  final AsyncValue<UserModel?> userAsync;
  final AsyncValue<StreakModel?> streakAsync;

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
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

            if (user.weeklyDrinkingCost == null ||
                user.weeklyDrinkingCost! <= 0) {
              return const SizedBox.shrink();
            }

            final days = streak.calculateDaysFromStart() + 1;
            final totalSavings = SavingsCalculator.calculateTotalSavings(
              days: days,
              weeklyCost: user.weeklyDrinkingCost,
            );
            final dailySavings = SavingsCalculator.calculateDailySavings(
                user.weeklyDrinkingCost);

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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      SavingsCalculator.formatAmount(totalSavings),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1日あたり ${SavingsCalculator.formatAmount(dailySavings)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '（週あたり ${SavingsCalculator.formatAmount(user.weeklyDrinkingCost!)}）',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  }
}
