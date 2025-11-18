import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/profile/presentation/dialogs/logout_dialog.dart';
import 'package:shilaf/features/profile/presentation/dialogs/reset_streak_dialog.dart';
import 'package:shilaf/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileBottomActions extends ConsumerWidget {
  final dynamic user; // 実際の型に合わせて変更してください

  const ProfileBottomActions({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileMenuItem(
            icon: Icons.refresh,
            title: '継続日数のリセット',
            textColor: AppColors.warning,
            onTap: () {
              showResetStreakDialog(context, ref);
            },
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'ログアウト',
            textColor: Colors.red,
            onTap: () {
              showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }
}
