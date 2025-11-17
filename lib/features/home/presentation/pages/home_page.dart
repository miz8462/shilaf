import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/auth/providers/auth_provider.dart';
import 'package:shilaf/features/home/presentation/widgets/achievement_section.dart';
import 'package:shilaf/features/home/presentation/widgets/savings_card.dart';
import 'package:shilaf/features/home/presentation/widgets/streak_card.dart';
import 'package:shilaf/features/home/presentation/widgets/user_info_card.dart';
import 'package:shilaf/features/home/utils/date_formatter.dart';
import 'package:shilaf/features/milestones/data/models/milestone_model.dart';
import 'package:shilaf/features/milestones/providers/milestone_provider.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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

  /// 継続リセット用のダイアログを表示
  void _showResetStreakDialog(BuildContext rootContext, WidgetRef ref) {
    DateTime selectedBreakDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime selectedRestartDate = selectedBreakDate;
    bool isSubmitting = false;
    final scaffoldMessenger = ScaffoldMessenger.of(rootContext);

    Future<DateTime?> pickDate({
      required DateTime initialDate,
      required DateTime firstDate,
      required DateTime lastDate,
      required String helpText,
    }) async {
      final picked = await showDatePicker(
        context: rootContext,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('ja', 'JP'),
        helpText: helpText,
        cancelText: 'キャンセル',
        confirmText: '決定',
      );
      if (picked == null) {
        return null;
      }
      return DateTime(picked.year, picked.month, picked.day);
    }

    showDialog(
      context: rootContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> selectBreakDate() async {
              final picked = await pickDate(
                initialDate: selectedBreakDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: '継続が切れた日を選択',
              );
              if (picked != null) {
                setState(() {
                  selectedBreakDate = picked;
                  if (selectedRestartDate.isBefore(selectedBreakDate)) {
                    selectedRestartDate = selectedBreakDate;
                  }
                });
              }
            }

            Future<void> selectRestartDate() async {
              final picked = await pickDate(
                initialDate: selectedRestartDate,
                firstDate: selectedBreakDate,
                lastDate: DateTime.now(),
                helpText: '再開した日を選択',
              );
              if (picked != null) {
                setState(() {
                  selectedRestartDate = picked;
                });
              }
            }

            Future<void> handleReset() async {
              setState(() {
                isSubmitting = true;
              });
              try {
                await ref
                    .read(streakNotifierProvider.notifier)
                    .resetStreak(selectedRestartDate);

                if (context.mounted) {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                }

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('継続記録をリセットしました'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('リセットに失敗しました: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } finally {
                if (context.mounted) {
                  setState(() {
                    isSubmitting = false;
                  });
                }
              }
            }

            final isValid = !selectedRestartDate.isBefore(selectedBreakDate);

            return AlertDialog(
              title: const Text('継続をリセット'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '継続記録は残したまま、再開日を設定し直します。\n'
                    '継続が途切れた日と再開した日を選んでください。',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cancel_schedule_send),
                    title: const Text('継続が切れた日'),
                    subtitle: Text(formatJapaneseDate(selectedBreakDate)),
                    onTap: isSubmitting ? null : selectBreakDate,
                    trailing: const Icon(Icons.calendar_today),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.play_circle_outline),
                    title: const Text('再開した日'),
                    subtitle: Text(formatJapaneseDate(selectedRestartDate)),
                    onTap: isSubmitting ? null : selectRestartDate,
                    trailing: const Icon(Icons.calendar_today),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '※ 継続が切れた翌日以降を再開日に選択できます',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('キャンセル'),
                ),
                ElevatedButton.icon(
                  onPressed: !isSubmitting && isValid ? handleReset : null,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(isSubmitting ? 'リセット中...' : 'リセット'),
                ),
              ],
            );
          },
        );
      },
    );
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

        // マイルストーン達成をチェック
        Future.microtask(() async {
          final milestoneNotifier =
              ref.read(milestoneNotifierProvider.notifier);
          final achievedMilestone =
              await milestoneNotifier.checkAndRecordMilestones();

          if (achievedMilestone != null && context.mounted) {
            // マイルストーン定義を取得
            final milestoneDef =
                MilestoneDefinition.getByDays(achievedMilestone.milestoneDays);
            if (milestoneDef != null) {
              // ポップアップを表示
              _showMilestoneDialog(context, milestoneDef);
            }
          }
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
              UserInfoCard(userAsync: userDataAsync),
              const SizedBox(height: 24),
              StreakCard(
                streakAsync: streakAsync,
                onResetPressed: () => _showResetStreakDialog(context, ref),
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
      ),
    );
  }
}
