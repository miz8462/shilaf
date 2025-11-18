import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/home/presentation/widgets/achievement_section.dart';
import 'package:shilaf/features/home/presentation/widgets/savings_card.dart';
import 'package:shilaf/features/home/presentation/widgets/streak_card.dart';
import 'package:shilaf/features/milestones/data/models/milestone_model.dart';
import 'package:shilaf/features/milestones/providers/milestone_provider.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  // ConsumerWidgetから変更
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 新しく追加
  /// マイルストーン達成ダイアログを表示
  void _showMilestoneDialog(
      BuildContext context, MilestoneDefinition milestone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 絵文字
              Text(
                milestone.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              // タイトル
              Text(
                milestone.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // 説明
              Text(
                milestone.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('素晴らしい！'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ユーザーデータを取得
    final userDataAsync = ref.watch(currentUserDataProvider);
    // 継続日数を取得
    final streakAsync = ref.watch(currentStreakProvider);

    // ホーム画面表示時に継続日数をDBに同期
    ref.listen(currentStreakProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // mounted チェックを追加
        if (!mounted) return;

        // バックグラウンドで更新（エラーは無視）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(streakNotifierProvider.notifier).updateStreakDays();
        });

        // マイルストーン達成をチェック
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          final milestoneNotifier =
              ref.read(milestoneNotifierProvider.notifier);
          final achievedMilestone =
              await milestoneNotifier.checkAndRecordMilestones();

          if (achievedMilestone != null && mounted) {
            // マイルストーン定義を取得
            final milestoneDef =
                MilestoneDefinition.getByDays(achievedMilestone.milestoneDays);
            if (milestoneDef != null) {
              // ポップアップを表示
              // ignore: use_build_context_synchronously
              _showMilestoneDialog(context, milestoneDef);
            }
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shilaf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // UserInfoCard(userAsync: userDataAsync),
            const SizedBox(height: 24),
            StreakCard(
              streakAsync: streakAsync,
            ),
            const SizedBox(height: 24),
            SavingsCard(
              userAsync: userDataAsync,
              streakAsync: streakAsync,
            ),
            const SizedBox(height: 24),
            const AchievementSection(),
          ],
        ),
      ),
    );
  }
}
