import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/home/utils/date_formatter.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

/// 継続リセット用のダイアログを表示
void showResetStreakDialog(BuildContext rootContext, WidgetRef ref) {
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
            title: const Text('リセット'),
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
                    '※ 継続が切れた日以降を再開日に選択できます',
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
              ElevatedButton(
                onPressed: !isSubmitting && isValid ? handleReset : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('リセット中...'),
                        ],
                      )
                    : const Text('リセット'),
              ),
            ],
          );
        },
      );
    },
  );
}
